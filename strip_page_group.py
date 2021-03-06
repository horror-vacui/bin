# from Rufflewind
# https://tex.stackexchange.com/questions/76273/multiple-pdfs-with-page-group-included-in-a-single-page-warning
#
# Removes the pdf groups from the pdf.
# Usage of the whole toolchain:
# qpdf --qdf input.pdf - | python strip_page_group.py | fix-qdf >output.pdf

import re, sys

stdin = getattr(sys.stdin, "buffer", sys.stdin)
stdout = getattr(sys.stdout, "buffer", sys.stdout)
stderr = getattr(sys.stderr, "buffer", sys.stderr)

page_group = None
for line in stdin:
    if page_group is None:
        if line.rstrip() == b"  /Group <<":
            page_group = [line]
        else:
            stdout.write(line)
    else:
        page_group.append(line)
        if line.rstrip() == b"  >>":
            break
else:
    if page_group:
        stdout.write(b"".join(page_group))
        page_group = None
for line in stdin:
    stdout.write(line)
stdout.flush()

if page_group:
    stderr.write(b"".join(page_group))
else:
    stderr.write(b"note: did not find page group\n")
