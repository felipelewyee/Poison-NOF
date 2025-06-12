using DoNOF

mol = """
0 1
C     0.00000000  0.00000000  0.00000000
F     0.76656406  -0.76656406  0.76656406
F     -0.76656406  0.76656406  0.76656406
F     -0.76656406  -0.76656406  -0.76656406
F     0.76656406  0.76656406  -0.76656406
"""

bset,p = DoNOF.molecule(mol,"def2-qzvp",spherical=true)

p.title = "G2RC_10_61"

p.ipnof = 8
p.ista = 3

p.RI = true
p.maxit = 40

p.maxloop = 10

#DoNOF.set_ncwo(p,1)
p.h_cut = 0.025*sqrt(2)

C = DoNOF.read_C(title=p.title)
n = DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
