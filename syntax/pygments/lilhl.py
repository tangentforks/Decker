#!/usr/bin/env python
"""
Lil Language Syntax Highlighter

A command-line tool for syntax highlighting Lil source code using Pygments.
"""

import os
import sys
import argparse
from pygments import highlight
from pygments.formatters import HtmlFormatter, Terminal256Formatter
from lil import LilLexer

def main():
    # Create the argument parser with example in help text
    parser = argparse.ArgumentParser(
        description='Highlight Lil language code', 
        epilog=f"With no arguments, reads from stdin."
    )
    parser.add_argument('file', nargs='?', default='-', 
                        help='Path to Lil file (default: read from stdin)')
    parser.add_argument('--html', action='store_true',
                        help='Output HTML instead of terminal colors')
    parser.add_argument('--spaces', type=int, default=2,
                        help='Number of spaces to replace each tab (default: 2)')
    parser.add_argument('--style', default='monokai',
                        help='Pygments style to use (default: monokai, options: monokai, one-dark, dracula, native, fruity)')
    args = parser.parse_args()
    
    # Get code from file or stdin
    if args.file == '-':
        # Read from stdin
        code = sys.stdin.read()
    else:
        try:
            with open(args.file, 'r') as f:
                code = f.read()
        except FileNotFoundError:
            print(f"Error: File not found: {args.file}", file=sys.stderr)
            return 1
        except Exception as e:
            print(f"Error reading file: {e}", file=sys.stderr)
            return 1
    
    # Replace tabs with spaces in the code
    spaces = ' ' * args.spaces
    code = code.replace('\t', spaces)
    
    # Apply highlighting
    if args.html:
        formatter = HtmlFormatter(linenos=True, full=True, style='default')
        html = highlight(code, LilLexer(), formatter)
        print(html)
    else:
        # Terminal output with selected built-in Pygments style
        formatter = Terminal256Formatter(style=args.style)
        
        highlighted = highlight(code, LilLexer(), formatter)
        print(highlighted, end='')  # Don't add extra newline
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
