using DoNOF

mol = """
1 2
   H          0.00000000      0.00000000     -0.79295577
   H          0.00000000      0.00000000      0.79295577
"""

bset,p = DoNOF.molecule(mol,"def2-qzvp",spherical=true)

p.title = "SIE4x4-h2+_1.5"

p.ipnof = 7

p.RI = true
p.maxit = 40

p.maxloop = 10

DoNOF.set_ncwo(p,1)

C = DoNOF.read_C(title=p.title)
n = DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
