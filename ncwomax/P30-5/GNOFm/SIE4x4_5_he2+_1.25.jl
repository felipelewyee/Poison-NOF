using DoNOF

mol = """
1 2
He     0.00000000  0.00000000  -0.67137733
He     0.00000000  0.00000000  0.67137733
"""

bset,p = DoNOF.molecule(mol,"def2-qzvp",spherical=true)

p.title = "SIE4x4_5_he2+_1.25"

p.ipnof = 9

p.RI = true
p.maxit = 40

p.maxloop = 10

#DoNOF.set_ncwo(p,1)

C = DoNOF.read_C(title=p.title)
n = nothing#DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
