import setuptools
from pathlib import Path

root_dir = Path(__file__).absolute().parent
with (root_dir / 'VERSION').open() as f:
    version = f.read()
with (root_dir / 'README.rst').open() as f:
    long_description = f.read()
with (root_dir / 'requirements.in').open() as f:
    requirements = f.read().splitlines()


setuptools.setup(
    name='geonature-atlas',
    version=version,
    description="Atlas WEB dynamique Faune-Flore basé sur les données présentes dans la synthèse de GeoNature",
    long_description=long_description,
    long_description_content_type='text/x-rst',
    maintainer='Parcs nationaux des Écrins et des Cévennes',
    maintainer_email='geonature@ecrins-parcnational.fr',
    url='https://github.com/PnX-SI/GeoNature-Atlas',
    packages=setuptools.find_packages('.'),
    #package_dir={'': 'src'},
    install_requires=requirements,
    classifiers=['Development Status :: 1 - Planning',
                 'Intended Audience :: Developers',
                 'Natural Language :: English',
                 'Programming Language :: Python :: 3',
                 'License :: OSI Approved :: GNU General Public License v3',
                 'Operating System :: OS Independent'],
)

