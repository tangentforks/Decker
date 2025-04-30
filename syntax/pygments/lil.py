"""
    pygments.lexers.lil
    ~~~~~~~~~~~~~~~~~

    Lexer for Lil language (Decker)

    :copyright: Copyright 2023
"""

from pygments.lexer import RegexLexer, bygroups, words
from pygments.token import Text, Comment, Operator, Keyword, Name, String, \
    Number, Punctuation, Error

class LilLexer(RegexLexer):
    """
    For Lil source code.
    """

    name = 'Lil'
    aliases = ['lil']
    filenames = ['*.lil']
    mimetypes = ['text/x-lil', 'application/x-lil']

    tokens = {
        'root': [
            (r'\s+', Text),
            (r'#.*?$', Comment.Single),
            
            # Keywords
            (words((
                'if', 'else', 'elseif', 'end', 'while', 'each', 'send', 'do',
                'select', 'extract', 'update', 'insert', 'into', 'from', 'where',
                'by', 'orderby', 'asc', 'desc', 'with', 'local'
            ), suffix=r'\b'), Keyword),
            
            # Built-in primitives
            (words((
                'floor', 'cos', 'sin', 'tan', 'exp', 'ln', 'sqrt',
                'sum', 'prod', 'raze', 'min', 'max', 'typeof', 'count',
                'first', 'last', 'range', 'keys', 'list', 'flip', 'rows',
                'cols', 'table', 'mag', 'heading', 'unit', 'split', 'fuse',
                'like', 'dict', 'take', 'window', 'drop', 'limit', 'in',
                'unless', 'join', 'cross', 'parse', 'format'
            ), suffix=r'\b'), Operator.Word),

            # Built-in functions
            (words((
                'show', 'panic', 'print', 'play', 'go', 'transition', 'brush',
                'sleep', 'array', 'image', 'sound', 'newdeck', 'eval', 'random',
                'readcsv', 'writecsv', 'readxml', 'writexml', 'alert', 'read',
                'write', 'input', 'error', 'dir', 'path', 'exit', 'shell',
                'import'
            ), suffix=r'\b'), Name.Function),
            
            # Function definition
            (r'(on)(\s+)([_?a-zA-Z][_?a-zA-Z0-9]*)',
             bygroups(Keyword, Text, Name.Function)),
            
            # Strings with escapes
            (r'"', String.Double, 'string'),
            
            # Numbers
            (r'-?\d+\.\d*', Number.Float),
            (r'-?\d+', Number.Integer),
            
            # Brackets and parentheses
            (r'[\[\]{}()]', Punctuation),
            
            # Other operators
            (r'[:.=+\-*/<>%&|^!~,]+', Operator),
            
            # Identifiers and function calls
            (r'[_?a-zA-Z][_?a-zA-Z0-9]*(?=\s*\[)', Name.Function),  # Function calls
            (r'[_?a-zA-Z][_?a-zA-Z0-9]*', Name.Variable),  # Identifiers
        ],
        'string': [
            (r'[^"\\]+', String.Double),
            (r'\\[n"\\]', String.Escape),
            (r'\\', Error),  # Invalid escape
            (r'"', String.Double, '#pop'),
        ],
    }
