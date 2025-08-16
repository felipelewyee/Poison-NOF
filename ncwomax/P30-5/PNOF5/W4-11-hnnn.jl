using DoNOF

mol = """
0 1
H        1.078972   -1.381810    0.000000 
N        0.093770   -1.129880    0.000000 
N        0.000000    0.111098    0.000000 
N       -0.247909    1.216183    0.000000 
"""

bset,p = DoNOF.molecule(mol,"def2-qzvp",spherical=true)

p.title = "W4-11-hnnn"

p.ipnof = 8

p.RI = true
p.maxit = 40

p.maxloop = 10

DoNOF.set_ncwo(p,1)

C = DoNOF.read_C(title=p.title)
n = DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
