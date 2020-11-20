## Guide to release new version of python-bindings
The developer who is releasing a new version of the python-bindings is expected to follow this work flow

1. The release of the `python-bindings` repository is made directly from the latest commit of the `develop` branch (no independent release branch).

2. Define the new version via `git tag v2.1.1.1`. We use the [python-versioneer](https://github.com/python-versioneer/python-versioneer/) for maintaining the version. *Note:* If a pre-release version is being made then the `rc` key should be attached (i.e. `git tag v2.1.1.1rc1`).

3. [Open a Pull Request from `develop` --> `master`](https://github.com/precice/python-bindings/compare/master...develop) named after the version (i.e. `Release v2.1.1.1`) and briefly describe the new features of the release in the PR description.

4. [Draft a New Release](https://github.com/precice/python-bindings/releases/new) in the `Releases` section of the repository page in a web browser. The release tag needs to be the exact version number (i.e.`v2.1.1.1` or `v2.1.1.1rc1`, compare to [existing tags](https://github.com/precice/python-bindings/tags)). Use `@target:master`. Release title is also the version number (i.e. `v2.1.1.1` or `v2.1.1.1rc1`, compare to [existing releases](https://github.com/precice/python-bindings/tags)).
*Note:* If it is a pre-release then the option *This is a pre-release* needs to be selected at the bottom of the page. Use `@target:develop` for a pre-release, since we will never merge a pre-release into master.

    a) If a pre-release is made: Directly hit the "Publish release" button in your Release Draft. Now you can check the artifacts (e.g. release on [PyPI](https://pypi.org/project/pyprecice/#history)) of the release. *Note:* As soon as a new tag is created github actions will take care of deploying the new version on PyPI using [this workflow](https://github.com/precice/python-bindings/actions?query=workflow%3A%22Upload+Python+Package%22).

    b) If this is a "real" release: As soon as one approving review is made, merge the release PR (`develop`) into `master`.

6. Merge `master` into `develop` for synchronization of `develop`.

7. If everything is in order up to this point then the new version can be released by hitting the "Publish release" button in your Release Draft.

8. Update Spack package (refer to `python-bindings/spack/README.md`).
