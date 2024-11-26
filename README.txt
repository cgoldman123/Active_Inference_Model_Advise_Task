% README File
PLEASE NOTE THIS CODE IS CURRENTLY IN DEVELOPMENT
main_advise.m is the main file for fitting and simulating behavior in the Advise (Epistemic T-Maze) Task!

Note that spm12 must be downloaded and the path must be added in main_advise.m (https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)
Additionally, the path to the active inference tutorial scripts may be added to main_advise.m for plotting code (https://www.sciencedirect.com/science/article/pii/S0022249621000973)


-------------------------------------------------------------------------------------------------------------

Noteworthy Commits 

Commit on 12/12/23: "Multiple Changes to VBX"
    In VBX, I changed calculation of probability of actions. 

    Using the committed code, I fit alpha, p_ha, 3 omegas, scalar on novelty term.
    Put results in L:/rsmith/.../advise_task/fitting_actual_data/advise_fits_alpha_and_novelty_scalar
