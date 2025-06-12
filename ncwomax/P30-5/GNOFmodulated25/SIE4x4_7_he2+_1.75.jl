using DoNOF

mol = """
1 2
He     0.00000000  0.00000000  -0.93992827
He     0.00000000  0.00000000  0.93992827
"""

bset,p = DoNOF.molecule(mol,"def2-qzvp",spherical=true)

p.title = "SIE4x4_7_he2+_1.75"

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
