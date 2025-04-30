from setuptools import setup, find_packages

setup(
    name='pygments-lil',
    version='0.1',
    description='Pygments lexer for Lil language',
    author='Decker Project',
    packages=find_packages(),
    entry_points='''
        [pygments.lexers]
        lil=lil:LilLexer
    ''',
    install_requires=['pygments']
)