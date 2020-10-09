## Guide to release new version of python-bindings
The developer who is releasing a new version of the python-bindings is expected to follow this work flow

1. The release of the `python-bindings` repository is made directly from the latest commit of the `develop` branch (no independent release branch).

2. Bump the version to the appropriately in [`setup.py`](https://github.com/precice/python-bindings/blob/develop/setup.py) (i.e. `precice_version = version.Version("2.1.1")` and `bindings_version = version.Version("1")`). *Note:* If a pre-release version is being made then the `rc` key in the `bindings_version` attached (i.e. `bindings_version = version.Version("1rc1")`).

3. [Open a Pull Request from `develop` --> `master`](https://github.com/precice/python-bindings/compare/master...develop) named after the version (i.e. `Release v2.1.1.1`) and briefly describe the new features of the release in the PR description.

4. [Draft a New Release](https://github.com/precice/python-bindings/releases/new) in the `Releases` section of the repository page in a web browser. The release tag needs to be the exact version number (i.e.`v2.1.1.1` or `v2.1.1.1rc1`, compare to [existing tags](https://github.com/precice/python-bindings/tags)). Release title is also the version number (i.e. `v2.1.1.1` or `v2.1.1.1rc1`, compare to [existing releases](https://github.com/precice/python-bindings/tags)). *Note:* If it is a pre-release then the option *This is a pre-release* needs to be selected at the bottom of the page.

5. If everything is in order up to this point then the new version can be released.

6. If a pre-release is made then this is a good chance for checking of the artifacts (e.g. release on [PyPI](https://pypi.org/project/pyprecice/#history)) of the release. *Note:* As soon as a new tag is created github actions will take care of deploying the new version on PyPI using [this workflow](https://github.com/precice/python-bindings/actions?query=workflow%3A%22Upload+Python+Package%22).

7. Merge the release PR (`develop`) into `master`.

8. Merge `master` into `develop` for synchronization of `develop`.
