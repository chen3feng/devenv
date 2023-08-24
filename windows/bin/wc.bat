@echo off

set argc=0
for %%x in (%*) do Set /A argc+=1

set args=
for %%x in (%*) do if not "%%x" == "-l" set args=%args% %%x

find /c /v "" %args%
