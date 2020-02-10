# Install Dependencies

* [preCICE](https://github.com/precice/precice)
* [python bindings](https://github.com/precice/python-bindings)
* Run in this directory `pip3 install --user -r requirements.txt`

# Run

You can test the dummy solver by coupling two instances with each other. Open two terminals and run
 * `python3 solverdummy.py precice-config.xml SolverOne MeshOne`
 * `python3 solverdummy.py precice-config.xml SolverTwo MeshTwo`

## parallel version

For the parallel verison of the solverdummy, you have to run add the command `mpirun -n <N>` to the  commands from above.

# Next Steps

If you want to couple any other solver against this dummy solver be sure to adjust the preCICE configuration (participant names, mesh names, data names etc.) to the needs of your solver, compare our [step-by-step guide for new adapters](https://github.com/precice/precice/wiki/Adapter-Example).
