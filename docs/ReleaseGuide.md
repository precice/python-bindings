# Guide to release new version of python-bindings

The developer who is releasing a new version of the python-bindings is expected to follow this work flow:

The release of the `python-bindings` repository is made directly from a release branch called `python-bindings-v2.1.1.1`. This branch is mainly needed to help other developers with testing.

1. Create a branch called `python-bindings-v2.1.1.1` from the latest commit of the `develop` branch.

2. [Open a Pull Request `master` <-- `python-bindings-v2.1.1.1`](https://github.com/precice/python-bindings/compare/master...master) named after the version (i.e. `Release v2.1.1.1`) and briefly describe the new features of the release in the PR description.

3. Bump the version in the following places:

    * `CHANGELOG.md` on `python-bindings-v2.1.1.1`.
    * There is no need to bump the version anywhere else, since we use the [python-versioneer](https://github.com/python-versioneer/python-versioneer/) for maintaining the version everywhere else.

4. [Draft a New Release](https://github.com/precice/python-bindings/releases/new) in the `Releases` section of the repository page in a web browser.

    * The release tag needs to be the exact version number (i.e.`v2.1.1.1` or `v2.1.1.1rc1`, compare to [existing tags](https://github.com/precice/python-bindings/tags)).
    * If this is a stable release, use `@target:master`. If this is a pre-release, use `@target:python-bindings-v2.1.1.1`. If you are making a pre-release, **directly skip to the [pre-release](#pre-release) section below**.
    * Release title is also the version number (i.e. `v2.1.1.1` or `v2.1.1.1rc1`, compare to [existing releases](https://github.com/precice/python-bindings/tags)).

5. As soon as one approving review is made, merge the release PR (from `python-bindings-v2.1.1.1`) into `master`.

6. Merge `master` into `develop` for synchronization of `develop`.

7. If everything is in order up to this point then the new version can be released by hitting the "Publish release" button in your release Draft. This will create the corresponding tag and trigger [publishing the release to PyPI](https://github.com/precice/python-bindings/actions?query=workflow%3A%22Upload+Python+Package%22).

8. Add an empty commit on master by running the steps:

    ```bash
    git checkout master
    git commit --allow-empty -m "post-tag bump"
    git push
    ```

    Check that everything is in order via `git log`. Important: The `tag` and `origin/master` should not point to the same commit. For example:

   ```bash
   commit 44b715dde4e3194fa69e61045089ca4ec6925fe3 (HEAD -> master, origin/master)
   Author: Benjamin Rodenberg <benjamin.rodenberg@in.tum.de>
   Date:   Wed Oct 20 10:52:41 2021 +0200

       post-tag bump

   commit d2645cc51f84ad5eda43b9c673400aada8e1505a (tag: v2.3.0.1)
   Merge: 2039557 aca2354
   Author: Benjamin Rodenberg <benjamin.rodenberg@in.tum.de>
   Date:   Tue Oct 19 12:57:24 2021 +0200

       Merge pull request #132 from precice/python-bindings-v2.3.0.1

       Release v2.3.0.1
   ```

   For more details refer to https://github.com/precice/python-bindings/issues/109 and https://github.com/python-versioneer/python-versioneer/issues/217.

9. *Temporarily not maintained* Update Spack package (refer to `python-bindings/spack/README.md`).

## Pre-release

A pre-release branch is never merged into a master branch. After creating the branch and drafting a release, directly hit the "Publish release" button in your Release Draft. Now you can check the pre-release artifacts (e.g. release on [PyPI](https://pypi.org/project/pyprecice/#history)) of the release. No further action is required for a pre-release.
