"""
NPU算子Python接口包设置
"""

from setuptools import setup, find_packages

setup(
    name="npu_ops",
    version="0.1.0",
    description="NPU算子Python接口封装",
    author="NPU Team",
    packages=find_packages(),
    install_requires=[
        "torch>=2.5.1",
        "numpy>=1.19.0",
        "pathlib;python_version<'3.4'",
    ],
    python_requires=">=3.6",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
    ],
    entry_points={
        'console_scripts': [
            'npu-test-basic=npu_ops.test_basic_ops:main',
            'npu-test-e2e=npu_ops.test_e2e:main',
        ],
    },
)
