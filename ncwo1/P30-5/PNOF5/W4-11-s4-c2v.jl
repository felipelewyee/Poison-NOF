using DoNOF

mol = """
0 1
S        0.000000    1.552343    0.921961 
S        0.000000    1.068508   -0.921961 
S        0.000000   -1.068508   -0.921961 
S        0.000000   -1.552343    0.921961 
"""

bset,p = DoNOF.molecule(mol,"def2-qzvp",spherical=true)

p.title = "W4-11-s4-c2v"

p.ipnof = 5

p.RI = true
p.maxit = 40

p.maxloop = 10

DoNOF.set_ncwo(p,1)

C = DoNOF.read_C(title=p.title)
n = DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
