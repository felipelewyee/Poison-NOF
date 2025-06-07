using DoNOF

mol = """
0 1
C     0.000000  0.000000  0.620000
C     0.000000  0.000000  -0.620000
"""

bset,p = DoNOF.molecule(mol,"cc-pvtz",spherical=true)

p.title = "W4-11_130_c2"

p.ipnof = 9

p.RI = true
p.maxit = 40

p.maxloop = 10

DoNOF.set_ncwo(p,1)
p.h_cut = 0.020*sqrt(2)

C = nothing#DoNOF.read_C(title=p.title)
n = nothing#DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
