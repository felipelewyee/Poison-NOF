using DoNOF

mol = """
0 1
   H          0.00000000      0.00000000     -0.37159115
   H          0.00000000      0.00000000      0.37159115
"""

bset,p = DoNOF.molecule(mol,"def2-qzvp",spherical=true)

p.title = "G2RC-1"

p.ipnof = 5

p.RI = true
p.maxit = 40

p.maxloop = 10

#DoNOF.set_ncwo(p,1)

C = DoNOF.read_C(title=p.title)
n = DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
