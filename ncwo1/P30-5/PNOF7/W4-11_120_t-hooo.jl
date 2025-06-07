using DoNOF

mol = """
0 2
O     1.174393  0.194313  0.000000
O     0.000000  0.553180  0.000000
O     -0.950471  -0.717715  0.000000
H     -1.791374  -0.238229  0.000000
"""

bset,p = DoNOF.molecule(mol,"cc-pvtz",spherical=true)

p.title = "W4-11_120_t-hooo"

p.ipnof = 7

p.RI = true
p.maxit = 40

p.maxloop = 10

DoNOF.set_ncwo(p,1)

C = nothing#DoNOF.read_C(title=p.title)
n = nothing#DoNOF.read_n(title=p.title)

DoNOF.energy(bset,p,C=C,n=n,do_hfidr=false,do_m_diagnostic=true)
