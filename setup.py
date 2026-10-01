from setuptools import setup, find_packages

setup(
    name="volume-osd",
    version="1.0.0",
    description="Sleek, fluid-animated volume & media on-screen display HUD",
    author="FluidOSD Contributors",
    url="https://github.com/shubbo/volume-osd",
    packages=find_packages(),
    python_requires=">=3.8",
    install_requires=[
        "PyQt5>=5.15.0",
    ],
    entry_points={
        "console_scripts": [
            "volume-osd=volume_osd.cli:main",
        ],
    },
    classifiers=[
        "Operating System :: POSIX :: Linux",
        "Operating System :: MacOS",
        "Operating System :: Microsoft :: Windows",
        "Programming Language :: Python :: 3",
        "Topic :: Desktop Environment",
        "License :: OSI Approved :: MIT License",
    ],
)
