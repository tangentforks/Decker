# Lil Syntax Highlighting for Pygments

This directory contains a Pygments lexer for the Lil language used by Decker.

## Quick Usage

The `lilhl.py` command-line tool provides an easy way to highlight Lil code:

```bash
# Highlight a file with terminal colors
./lilhl.py path/to/file.lil

# Highlight stdin input
cat path/to/file.lil | ./lilhl.py -

# Generate HTML output
./lilhl.py --html path/to/file.lil > output.html
```

## Features

The Lil syntax highlighter supports:

- Keywords and control flow (`if`, `else`, `while`, `each`, etc.)
- Primitive functions and built-ins 
- Function definitions and calls
- Comments, strings, and numbers
- Operators and punctuation

It's designed to be comprehensive, including all language elements from the other syntax highlighters in the codebase, plus additional built-ins found in the example files.

## Installation

To install this lexer for use with Pygments:

1. Install Pygments if you haven't already:
   ```
   pip install pygments
   ```

2. Copy the `lil.py` file to a location in your Python path, or create a proper Python package.

3. Register the lexer with Pygments by creating an entry point. Create a `setup.py` file:

   ```python
   from setuptools import setup, find_packages

   setup(
       name='pygments-lil',
       version='0.1',
       description='Pygments lexer for Lil language',
       packages=find_packages(),
       entry_points='''
           [pygments.lexers]
           lil=lil:LilLexer
       ''',
       install_requires=['pygments']
   )
   ```

4. Install the package:
   ```
   pip install -e .
   ```

## Programmatic Usage

After installation, you can use the lexer with Pygments:

```python
from pygments import highlight
from pygments.formatters import HtmlFormatter
from lil import LilLexer

code = 'on myFunction a b # This is a comment\n  if a > b\n    return a\n  end\nend'
print(highlight(code, LilLexer(), HtmlFormatter()))
```

Or from the command line:

```
pygmentize -l lil file.lil
```