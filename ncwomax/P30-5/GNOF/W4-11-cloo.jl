using DoNOF

mol = """
0 2
Cl      -0.560974   -0.994637    0.000000 
O        0.000000    0.958712    0.000000 
O        1.192069    1.154892    0.000000 
"""

bset,p = DoNOF.molecule(mol,"def2-qzvp",spherical=true)

p.title = "W4-11-cloo"

p.ipnof = 8

p.RI = true
p.maxit = 40

p.maxloop = 10

DoNOF.set_ncwo(p,1)

C = DoNOF.read_C(title=p.title)
n = DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
