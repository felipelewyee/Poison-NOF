using DoNOF

mol = """
0 2
   H         -0.26904536     -1.53918757      0.00000000
   O         -0.82676854     -0.22999776      0.00000000
   N          0.03423988      0.64855342      0.00000000
   N          1.06157401      1.12063191      0.00000000
"""

bset,p = DoNOF.molecule(mol,"def2-qzvp",spherical=true)

p.title = "BH76-n2ohts"

p.ipnof = 7

p.RI = true
p.maxit = 40

p.maxloop = 10

DoNOF.set_ncwo(p,1)

C = DoNOF.read_C(title=p.title)
n = DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
