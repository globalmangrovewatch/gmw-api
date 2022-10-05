web: export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/app/.apt/usr/lib/x86_64-linux-gnu/lapack:/app/.apt/usr/lib/x86_64-linux-gnu/blas && bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}
