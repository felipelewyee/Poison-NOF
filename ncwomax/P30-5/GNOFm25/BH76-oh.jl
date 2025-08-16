using DoNOF

mol = """
0 2
   O          0.00000000      0.00000000      0.48444828
   H          0.00000000      0.00000000     -0.48444828
"""

bset,p = DoNOF.molecule(mol,"def2-qzvp",spherical=true)

p.title = "BH76-oh"

p.ipnof = 8
p.ista = 1
p.h_cut = 0.025 * sqrt(2)

p.RI = true
p.maxit = 40

p.maxloop = 10

DoNOF.set_ncwo(p,1)

C = DoNOF.read_C(title=p.title)
n = DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
