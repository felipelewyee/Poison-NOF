using DoNOF

mol = """
0 1
C     0.00000000  0.00000000  0.00000000
Cl     1.03344587  -1.03344587  1.03344587
Cl     -1.03344587  1.03344587  1.03344587
Cl     -1.03344587  -1.03344587  -1.03344587
Cl     1.03344587  1.03344587  -1.03344587
"""

bset,p = DoNOF.molecule(mol,"cc-pvtz",spherical=true)

p.title = "G2RC_10_62"

p.ipnof = 7

p.RI = true
p.maxit = 40

p.maxloop = 10

#DoNOF.set_ncwo(p,1)

C = DoNOF.read_C(title=p.title)
n = DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
