# Poison-NOF

Para ejecutar todos los yaml:
``` bash
for ncwo in ncwo1 ncwomax; do
    echo $ncwo
    cd $ncwo
    for set in P30-5 P30-10 P30-20; do
        echo $set
        cd $set
        for nof in PNOF5 PNOF7 GNOF GNOFm20 GNOFm25 GNOFs20 GNOFs25; do
            echo $nof 
            cd $nof
            julia --project=@analyzer ../../../utils/common.jl
            julia --project=@analyzer ../../../utils/cleaner.jl
            julia --project=@analyzer ../../../utils/analyzer.jl
            cd .. 
        done
        cd .. 
    done 
    cd ..
done
```

Para propagar notebooks
``` bash
for set in P30-5 P30-10 P30-20; do
    echo $set
    for method in PNOF5 PNOF7 GNOF GNOFm20 GNOFm25 GNOFs20 GNOFs25; do
        echo $method
        cp P30-5-GNOF-PP.ipynb ${set}-${method}-PP.ipynb 
        cp P30-5-GNOF-EP.ipynb ${set}-${method}-EP.ipynb
        sed -i -e "s/GNOF/${method}/g" ${set}-${method}-*.ipynb
    done
    sed -i -e "s/P30-5/${set}/g" ${set}-*.ipynb
done
sed -i -e "s/ncwo1/ncwomax/g" *-EP.ipynb
```

