#!/bin/sh

# libgmp hack
mkdir -p $HOME/usr/lib
ln -s /usr/lib/libgmp.so.3 $HOME/usr/lib/libgmp.so

# ghc
curl --silent http://www.haskell.org/ghc/dist/7.8.2/ghc-7.8.2-x86_64-unknown-linux.tar.bz2|tar xj
cd ghc-7.8.2/
./configure --prefix=$HOME/ghc --with-gmp-libraries=$HOME/usr/lib
make install
cd ..

# GHC space trimming (risky business)

# Remove haddock and hpc - no docs or coverage
rm $HOME/ghc/bin/haddock*
rm $HOME/ghc/lib/ghc-7.8.2/haddock
rm -r $HOME/ghc/lib/ghc-7.8.2/html
rm -r $HOME/ghc/lib/ghc-7.8.2/latex
# rm $HOME/ghc/bin/hp*
# rm -r $HOME/ghc/lib/ghc-7.8.2/hp*
# rm -r $HOME/ghc/lib/ghc-7.8.2/package.conf.d/hpc-0.5.1.1-*
# rm -r $HOME/ghc/lib/ghc-7.8.2/ghc-7.8.2
# rm -r $HOME/ghc/lib/ghc-7.8.2/package.conf.d/ghc-7.8.2-*
# rm -r $HOME/ghc/lib/ghc-7.8.2/package.conf.d/package.cache
echo "" > $HOME/ghc/lib/ghc-7.8.2/ghc-usage.txt
echo "" > $HOME/ghc/lib/ghc-7.8.2/ghci-usage.txt

# Remove duplicate libs
find $HOME/ghc/lib -name "*_p.a" -delete
find $HOME/ghc/lib -name "*.p_hi" -delete
find $HOME/ghc/lib -name "*.dyn_hi" -delete
find $HOME/ghc/lib -name "*HS*.so" -delete
find $HOME/ghc/lib -name "*HS*.o" -delete
find $HOME/ghc/lib -name "*_debug.a" -delete

# Don't need man or doc
rm -rf $HOME/ghc/share

# Strip binaries
strip --strip-unneeded $HOME/ghc/lib/ghc-7.8.2/{run,}ghc

export PATH=$PATH:$HOME/ghc/bin

# ldconfig for linker hack
ghc-pkg describe base > base.package.conf
sed -i "s/ld-options:/ld-options:\ -L\/app\/usr\/lib/" base.package.conf
ghc-pkg update base.package.conf

# cabal-install
curl --silent http://hackage.haskell.org/package/cabal-install-1.18.0.3/cabal-install-1.18.0.3.tar.gz |tar xz
cd cabal-install-1.18.0.3/
sh bootstrap.sh
cd ..

export PATH=$PATH:$HOME/.cabal

# Install a binary that Yesod needs separately
cabal update
cabal install happy
find $HOME/.cabal -name "*HS*.o" -delete
rm -rf $HOME/.cabal/{config,share,packages,logs}

tar cvzf ghc.tar.gz ghc
tar cvzf cabal.tar.gz .cabal
