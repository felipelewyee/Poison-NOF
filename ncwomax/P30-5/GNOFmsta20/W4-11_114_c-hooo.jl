using DoNOF

mol = """
0 2
O     1.143943  0.075354  0.000000
O     0.000000  0.576945  0.000000
O     -1.082114  -0.493872  0.000000
H     -0.494634  -1.267419  0.000000
"""

bset,p = DoNOF.molecule(mol,"def2-qzvp",spherical=true)

p.title = "W4-11_114_c-hooo"

p.ipnof = 8
p.ista = 2

p.RI = true
p.maxit = 40

p.maxloop = 10

#DoNOF.set_ncwo(p,1)

C = DoNOF.read_C(title=p.title)
n = DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
