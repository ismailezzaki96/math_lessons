#!/usr/bin/env python
import sys
import re
from pandocfilters import toJSONFilter, Math
from py_asciimath.translator.translator import (
    ASCIIMath2MathML,
    ASCIIMath2Tex,
    MathML2Tex,
    Tex2ASCIIMath
)
def is_latex(code):
    # Check for common LaTeX commands or environments
    latex_patterns = [
        r'\\[a-zA-Z]+',  # LaTeX commands
    ]
    return any(re.search(pattern, code) for pattern in latex_patterns)

def asciimath_to_latex(key, value, format, meta):
    if key == 'Math':
        mathtype, code = value
        if not is_latex(code):
            try:
                latex_code = ASCIIMath2TeX().translate(code)
                return Math(mathtype, latex_code)
            except Exception as e:
                print(f"Error converting to LaTeX: {e}", file=sys.stderr)
                return Math(mathtype, code)  # Return original if conversion fails
        else:
            return Math(mathtype, code)  # Return original LaTeX unchanged

if __name__ == "__main__":
    toJSONFilter(asciimath_to_latex)

# import re
# import subprocess
#
# from pandocfilters import Math, RawInline, toJSONFilter
# from py_asciimath.translator.translator import (
#     ASCIIMath2Tex,
# )
#
# asciimath2tex = ASCIIMath2Tex(log=False, inplace=False)
#
#
# def change_math(key, value, format, meta):
#     if key == "Math":
#         subprocess.run(["notify-send", key, str(value)])
#         math_type, math_content = value
#         # Here we define the transformation we want to apply to the math equations
#         new_math_content = transform_math(math_content)
#         return Math(math_type, new_math_content)
#
#
# def transform_math(math_content):
#     # Define the transformation logic here
#     # For example, let's say we want to replace "x" with "y" in all equations
#     return math_content.replace("x", "y")
#
#
# def is_latex_math(expr):
#     # Heuristic to detect LaTeX math
#     latex_patterns = [
#         r"\\[a-zA-Z]+",  # LaTeX commands like \frac, \sqrt
#         # ignore \label
#         r"\{.*?\}",  # Braces used in LaTeX for grouping
#         r"\\left",  # LaTeX left delimiter
#         r"\\right",  # LaTeX right delimiter
#         r"\[.*?\]",  # Brackets used in LaTeX for optional arguments
#     ]
#     return any(re.search(pattern, expr) for pattern in latex_patterns)
#
#
# file = open("debug.txt", "w")
#
#
# def disable_math(key, value, format, meta):
#     if key == "Math":
#         # check if inline or display math
#         math_content = value[1].replace("$", "")
#         file.write(str(value) + "\n")
#         if value[0]["t"] == "InlineMath":
#             dilimiter = "$"
#         elif value[0]["t"] == "DisplayMath":
#             dilimiter = "$$"
#
#         if is_latex_math(math_content):
#             return RawInline("html", f"{dilimiter} {math_content} {dilimiter}")
#         try:
#             math_content = asciimath2tex.translate(
#                 math_content,
#                 displaystyle=False,
#                 from_file=False,
#                 pprint=False,
#             )
#         except Exception:
#             pass
#         math_content = math_content.replace("$", "")
#         return RawInline("html", f"{dilimiter} {math_content} {dilimiter} ")
#
#
# if __name__ == "__main__":
#     # calculate time to run the python script
#     toJSONFilter(disable_math)
