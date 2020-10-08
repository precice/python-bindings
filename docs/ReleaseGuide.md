## Guide to release new version of python-bindings
The developer who is releasing a new version of the python-bindings is expected to follow this work flow

1. Because the `python-bindings` repository is not big the release is made directly from the latest commit
of the `develop` branch.

2. Bump the version to the appropriate level in the `setup.py` file. If a pre-release version is being made
then the `rc` key in the version number should be attached appropriately. For example if the first 
pre-release version is being made then the key is `rc1`. If the second pre-release version is being made
then the key is `rc2`.

3. Open a Pull Requent from `develop` --> `master` and briefly describe the new features of the release
in the PR description.

4. Select the `Draft a New Release` option in the `Releases` section on the right side of the repository
page in a web browser. The release tag needs to be the exact version number. Release title is also the version
number. If it is a pre-release then the respective option needs to be selected at the bottom of the page.

5. If a pre-release is made then a check of the artifacts of the release is a good double check. 

6. If everything is in order upto this point then the new version can be released.

7. Merge the PR (`develop`) to `master`.

8. Merge `master` into `develop` to have the same commit on which the release was made as the latest commit in 
`develop`.
