from distutils.core import setup
from setuptools import find_packages

setup(name='hello-zmq',
      version='0.1',
      description='python implementation of RFC-424242',
      packages=find_packages(),
      requires=[
          'pyzmq',
          'docopt',
      ]
 )
