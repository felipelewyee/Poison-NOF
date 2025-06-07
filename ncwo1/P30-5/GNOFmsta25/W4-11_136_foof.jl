using DoNOF

mol = """
0 1
F     0.555710  1.384434  -0.493986
O     0.555710  0.268181  0.555734
O     -0.555710  -0.268181  0.555734
F     -0.555710  -1.384434  -0.493986
"""

bset,p = DoNOF.molecule(mol,"cc-pvtz",spherical=true)

p.title = "W4-11_136_foof"

p.ipnof = 9

p.RI = true
p.maxit = 40

p.maxloop = 10

DoNOF.set_ncwo(p,1)
p.h_cut = 0.025*sqrt(2)

C = nothing#DoNOF.read_C(title=p.title)
n = nothing#DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
