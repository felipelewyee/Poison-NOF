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

p.ipnof = 9

p.RI = true
p.maxit = 40

p.maxloop = 10

#DoNOF.set_ncwo(p,1)

C = DoNOF.read_C(title=p.title)
n = nothing#DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
