#!/usr/bin/env python


import sys
import re
from optparse import OptionParser


_MAX_LINE_LENGTH = 80
_INDENT = 2

_FUNCTION = re.compile(r'^(function)?\s*([A-Za-z_][A-Za-z0-9_:]+)\s*\(\s*\)\s*{?')
_TEST = re.compile(r'^(if|elif|while)\s*\[[^[]')
_VAR_ASSIGN = re.compile(r'\s*(local)?\s+([A-Za-z_][A-Za-z0-9_]*)=')
_LOCAL_VAR = re.compile(r'\s*(local)\s+([A-Za-z_][A-Za-z0-9_]*)$')
_LOCAL_VAR_COMMAND = re.compile(r'\s*local\s+[A-Za-z_][A-Za-z0-9_]*=\$\(')
_LOOP_WORDS = re.compile(r'^(then|do)$')
_MISSING_SPACES = re.compile(r'.*;(then|do)$')


class BashLint(object):
    def __init__(self, options):
        self.raw_lines = []
        self.lines = []  # Comment striped lines
        self.filename = ''
        self.only_check = options.only_check
        self.suppress = options.suppress.split(',')
        self.errors = []

    def check(self, filename):
        self._load(filename)
        if self.only_check:
            check_method = getattr(self, '_check_' + self.only_check, None)
            if check_method:
                check_method()
            else:
                print 'only-check: method %s not found' % self.only_check
        else:
            # All checking functions are starts with '_check_'
            for method in dir(self):
                if method.startswith('_check_'):
                    check_method = getattr(self, method)
                    check_method()

        self.errors.sort()
        for error in self.errors:
            print '%s:%d: %s: %s' % (self.filename, error[0], error[1], error[2])
        return not self.errors

    def _load(self, filename):
        self.raw_lines = open(filename).read().splitlines()
        self.lines = self._strip_comments(self.raw_lines)
        self.filename = filename

    def _is_comment_line(self, lineno):
        return self.raw_lines[lineno].strip().startswith('#')

    def _is_comment_start(self, line, i):
        if line[i] != '#':
            return False
        # '$#' or '\$'
        if (i > 1) and (line[i - 1] == '$' or line[i - 1] == '\\'):
            return False
        # ${#}
        if i > 2 and line[i - 1] == '{' and line[i - 2] == '$':
            return False
        return True

    def _find_string_end(self, line, i):
        expect_quota_end = line[i]
        i += 1
        while i < len(line):
            if line[i] == '\\' and i + 1 < len(line):
                ch2 = line[i + 1]
                if ch2 == '\\' or ch2 == '"' or ch2 == '\'':
                    i += 1
            elif line[i] == expect_quota_end:
                return i + 1
            i += 1
        return -1

    def _find_commont_start(self, line):
        i = 0
        while i < len(line):
            if self._is_comment_start(line, i):
                return i
            elif line[i] in '"\'':
                i = self._find_string_end(line, i)
                if i < 0:
                    return -1
            else:
                i += 1
        return -1

    def _strip_comments(self, lines):
        result = []
        for line in lines:
            pos = self._find_commont_start(line)
            if pos >= 0:
                line = line[:pos]
            result.append(line.rstrip())
        return result

    def _is_blank_line(self, lineno):
        return self.raw_lines[lineno].strip() == ''

    def _error(self, lineno, error_type, message):
        if error_type not in self.suppress:
            self.errors.append((lineno + 1, error_type, message))

    def _check_file_name(self):
        if not self.filename.islower():
            self._error(-1, 'filename', 'filename should be all lower case')

    def _check_function(self):
        for lineno, line in enumerate(self.lines):
            match = _FUNCTION.match(line)
            if match:
                name = match.group(2)
                if name.lower() != name:
                    self._error(
                            lineno, 'fnname',
                            'Invalid function name "%s", should be all lower case' % name)
                if not match.group(0).endswith('{'):
                    self._error(lineno, 'brace',
                                '"{" should be be put at the end of line')

    def _do_check_comment_content(self, lineno, comment):
        if comment.strip('#').strip() == '':  # Full line of '#'s
            return
        if not comment.lstrip('#').startswith(' '):
            self._error(lineno, 'comment',
                        'A space is required after #')

    def _check_comment(self):
        for lineno, line in enumerate(self.raw_lines):
            if lineno == 0 and line.startswith('#!'):  # shebang line
                continue
            striped_line = line.strip()
            if striped_line.startswith('#'):
                self._do_check_comment_content(lineno, striped_line)
            elif self.lines[lineno] != line.rstrip() and '#' in line:
                pos = self._find_commont_start(line)
                if pos > 0 and line[pos - 2:pos] != '  ':
                    self._error(lineno, 'comment', 'At least 2 spaces before #')
                self._do_check_comment_content(lineno, line[pos:])

    def _check_blank_line(self):
        for lineno, line in enumerate(self.raw_lines):
            match = _FUNCTION.match(line)
            if match:
                i = lineno - 1
                while i >= 0 and self._is_comment_line(i):
                    i -= 1
                if i <= 0:
                    continue

                if not self._is_blank_line(i):
                    self._error(lineno, 'blankline',
                                'Need a blank line between functions')

        # Check unnecessary blank lines
        first_blank = -1
        last_blank = -1
        for lineno, line in enumerate(self.raw_lines):
            if self._is_blank_line(lineno):
                if first_blank == -1:
                    first_blank = lineno
                last_blank = lineno
            else:
                if last_blank - first_blank >= 1:
                    self._error(first_blank + 1, 'blankline',
                               'Too many blank lines, keep only one')
                first_blank = -1
                last_blank = -1

    def _check_test(self):
        for lineno, line in enumerate(self.lines):
            match = _TEST.match(line.strip())
            if match:
                self._error(
                    lineno, 'test',
                    '[[ ... ]] is preferred over [, test and /usr/bin/[')

    def _check_line_length(self):
        for lineno, line in enumerate(self.raw_lines):
            if len(line) > _MAX_LINE_LENGTH:
                self._error(lineno, 'linelength',
                            'Maximum line length is %s characters.' % _MAX_LINE_LENGTH)

    def _check_space(self):
        for lineno, line in enumerate(self.raw_lines):
            if line.rstrip() != line:
                self._error(lineno, 'space', 'Extra spaces at line ending')
        for lineno, line in enumerate(self.lines):
            match = _MISSING_SPACES.match(line.strip())
            if match:
                self._error(lineno, 'space',
                        'Missing space before "%s"' % match.group(1))

    def _check_tab(self):
        for lineno, line in enumerate(self.raw_lines):
            if '\t' in line:
                self._error(lineno, 'space', "don't use tabs")

    def _line_indent(self, lineno):
        indent = 0
        line = self.raw_lines[lineno]
        while indent < len(line) and line[indent] == ' ':
            indent += 1
        return indent

    def _has_continuous_line(self, lineno):
        return self.raw_lines[lineno].endswith('\\')

    def _do_check_continuous_line_indent(self, lineno):
        '''Check continuous lines, return number of total continuous lines'''
        if not self._has_continuous_line(lineno):
            return 0
        org_lineno = lineno
        prev_line = self.raw_lines[lineno]
        prev_indent = self._line_indent(lineno)

        # Check first line
        if lineno + 1 < len(self.raw_lines):
            lineno += 1
            indent = self._line_indent(lineno)

            def is_valid_indent():
                if indent - _INDENT == prev_indent:
                    return True
                if indent > 0 and indent < len(prev_line):  # Allow align
                    if prev_line[indent] != ' ' and prev_line[indent - 1] == ' ':
                        return True
                return False

            if not is_valid_indent():
                self._error(lineno, 'indent',
                        'Indent %s spaces or align to somewhere after a space' % _INDENT)

            # Only one continuous line
            if not self._has_continuous_line(lineno):
                return 1

        # Check more lines
        prev_indent = indent
        while lineno + 1 < len(self.raw_lines):
            lineno += 1
            indent = self._line_indent(lineno)
            if indent != prev_indent:
                self._error(lineno, 'indent', 'Keep same indent as previous line')
            prev_indent = indent
            if not self._has_continuous_line(lineno):
                break

        return lineno - org_lineno

    def _check_indent(self):
        prev_indent = 0
        last_error_lineno = 0
        lineno = 0
        while lineno < len(self.raw_lines):
            if self._is_blank_line(lineno):
                lineno += 1
                continue
            indent = self._line_indent(lineno)
            skip = self._do_check_continuous_line_indent(lineno)
            if indent != prev_indent and abs(indent - prev_indent) != _INDENT:
                # Only report once for adjacent lines
                if lineno - last_error_lineno > 1:
                    self._error(lineno, 'indent', 'Indent should be %s spaces' % _INDENT)
                    last_error_lineno = lineno
            lineno += skip + 1
            prev_indent = indent

    def _check_varname(self):
        global_names = set()
        local_names = set()
        in_function = False
        for lineno, line in enumerate(self.lines):
            if _FUNCTION.match(line):
                in_function = True
            elif line.strip() == '}':
                in_function = False
                local_names.clear()
            else:
                match = _VAR_ASSIGN.match(line) or _LOCAL_VAR.match(line)
                if match:
                    local = match.group(1)
                    var = match.group(2)

                    if not (var.isupper() or var.islower()):
                        self._error(lineno, 'varname',
                            ('"%s": variable name should be all lower case, '
                             'constant name should be all upper case' % var))
                    if in_function:
                        if var not in global_names and var not in local_names:
                            local_names.add(var)
                            if local != 'local':
                                self._error(lineno, 'local',
                                    'Suggest declare function-specific variables with local: %s' % var)
                        if _LOCAL_VAR_COMMAND.match(line):
                            self._error(lineno, 'local',
                                    ('Declaration and assignment must be separate statements when the assignment value is provided by a command substitution; '
                                     'as the "local" builtin does not propagate the exit code from the command substitution.'))
                    else:
                        global_names.add(var)

    def _check_shebang(self):
        first_line = self.raw_lines[0] if self.raw_lines else ''
        if not self.filename.endswith('.sh'):
            if not first_line.startswith('#!'):
                self._error(0, 'shebang',
                        'Executable shell script need a shebang line(#!/bin/bash)')
        if first_line.startswith('#!') and not first_line.startswith('#!/bin/bash'):
            self._error(0, 'shebang',
                        'You should use bash (#!/bin/bash)')

    def _check_loop(self):
        for lineno, line in enumerate(self.lines):
            match = _LOOP_WORDS.match(line.strip())
            if match:
                self._error(lineno, 'loop',
                        'Put ; do and ; then on the same line as the while, for or if.')

    def _check_semicolon(self):
        for lineno, line in enumerate(self.lines):
            if line.endswith(';'):
                self._error(lineno, 'semicolon',
                            'The tariling ";" is unnecessary')

    def _check_eval(self):
        for lineno, line in enumerate(self.lines):
            if line.strip().startswith('eval '):
                self._error(lineno, 'eval', '"eval" is dangerous')


def main():
    parser = OptionParser()
    parser.add_option('--only-check', dest='only_check',
                      help="Only do specificed checking, for debugging.")
    parser.add_option('--suppress', dest='suppress', type=str, default='',
                      help="Checking to be suppressed, comma seperated.")
    (options, args) = parser.parse_args()
    error = True
    for filename in args:
        lint = BashLint(options)
        if not lint.check(filename):
            error = True
    sys.exit(1 if error else 0)


if __name__ == '__main__':
    main()
