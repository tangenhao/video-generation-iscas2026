# Convolution Modes

|No.|mode|ic_group_size|ifmap_shape|weight_shape|Comment|
|---|---|---|---|---|:-:|
|1|fp x fp|32|(ic_group, h, w, 32)|(oc_group, ic_group, kh, kw, 64, 32)|-|
|2|fp x bf|32|(ic_group, h, w, 32)|(oc_group, ic_group, kh, kw, 64, 32)|-|
|3|fp x i8|32|(ic_group x 2, h, w, 32)|(oc_group, ic_group, kh, kw, 64, 64)|读取一次weight，读取两次ifmap，做两次计算并累加|
|4|fp x i4|32|(ic_group x 4, h, w, 32)|(oc_group, ic_group, kh, kw, 64, 128)|读取一次ifmap，读取四次weight，做四次计算并累加|
|5|fp x fp, sparse|32|(ic_group, h, w, 32 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 32)|-|
|6|fp x bf, sparse|32|(ic_group, h, w, 32 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 32)|-|
|7|fp x i8, sparse|32|(ic_group x 2, h, w, 32 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 64)|读取一次weight，读取两次ifmap，做两次计算并累加|
|8|fp x i4, sparse|32|(ic_group x 4, h, w, 32 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 128)|读取一次ifmap，读取四次weight，做四次计算并累加|
|9|bf x fp|32|(ic_group, h, w, 32)|(oc_group, ic_group, kh, kw, 64, 32)|-|
|10|bf x bf|32|(ic_group, h, w, 32)|(oc_group, ic_group, kh, kw, 64, 32)|-|
|11|bf x i8|32|(ic_group x 2, h, w, 32)|(oc_group, ic_group, kh, kw, 64, 64)|读取一次weight，读取两次ifmap，做两次计算并累加|
|12|bf x i4|32|(ic_group x 4, h, w, 32)|(oc_group, ic_group, kh, kw, 64, 128)|读取一次ifmap，读取四次weight，做四次计算并累加|
|13|bf x fp, sparse|32|(ic_group, h, w, 32 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 32)|-|
|14|bf x bf, sparse|32|(ic_group, h, w, 32 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 32)|-|
|15|bf x i8, sparse|32|(ic_group x 2, h, w, 32 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 64)|读取一次weight，读取两次ifmap，做两次计算并累加|
|16|bf x i4, sparse|32|(ic_group x 4, h, w, 32 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 128)|读取一次ifmap，读取四次weight，做四次计算并累加|
|17|i8 x fp|32|(ic_group, h, w, 64)|(oc_group, ic_group x 2, kh, kw, 64, 32)|读一次ifmap，读一次weight，再重新读相同的ifmap，再读入新的ic_group的weight，并且累加|
|18|i8 x bf|32|(ic_group, h, w, 64)|(oc_group, ic_group x 2, kh, kw, 64, 32)|读一次ifmap，读一次weight，再重新读相同的ifmap，再读入新的ic_group的weight，并且累加|
|19|i8 x i8|64|(ic_group, h, w, 64)|(oc_group, ic_group, kh, kw, 64, 64)|-|
|20|i8 x i4|64|(ic_group x 2, h, w, 64)|(oc_group, ic_group, kh, kw, 64, 128)|读取一次weight，读取两次ifmap，做两次计算并累加|
|21|i8 x fp, sparse|32|(ic_group, h, w, 64 x sparse_ratio)|(oc_group, ic_group x 2, kh, kw, 64, 32)|读一次ifmap，读一次weight，再重新读相同的ifmap，再读入新的ic_group的weight，并且累加|
|22|i8 x bf, sparse|32|(ic_group, h, w, 64 x sparse_ratio)|(oc_group, ic_group x 2, kh, kw, 64, 32)|读一次ifmap，读一次weight，再重新读相同的ifmap，再读入新的ic_group的weight，并且累加|
|23|i8 x i8, sparse|64|(ic_group, h, w, 64 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 64)|-|
|24|i8 x i4, sparse|64|(ic_group x 2, h, w, 64 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 128)|读取一次weight，读取两次ifmap，做两次计算并累加|
|25|i8 x i8, pvsq|64|(ic_group, h, w, 64)|(oc_group, ic_group, kh, kw, 64, 64)|-|
|26|i8 x i4, pvsq|64|(ic_group x 2, h, w, 64)|(oc_group, ic_group, kh, kw, 64, 128)|读取一次weight，读取两次ifmap，做两次计算并累加|
|27|i8 x i8, pvsq, sparse|64|(ic_group, h, w, 64 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 64)|-|
|28|i8 x i4, pvsq, sparse|64|(ic_group x 2, h, w, 64 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 128)|读取一次weight，读取两次ifmap，做两次计算并累加|
|29|i8 x i8, outlier|64|(ic_group, h, w, 64)|(oc_group, ic_group, kh, kw, 64, 64)|-|
|30|i8 x i4, outlier|64|(ic_group x 2, h, w, 64)|(oc_group, ic_group, kh, kw, 64, 128)|读取一次weight，读取两次ifmap，做两次计算并累加|
|31|i8 x i8, outlier, sparse|64|(ic_group, h, w, 64 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 64)|-|
|32|i8 x i4, outlier, sparse|64|(ic_group x 2, h, w, 64 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 128)|读取一次weight，读取两次ifmap，做两次计算并累加|
|33|i8 x i4, non_uniform|64|(ic_group x 2, h, w, 64)|(oc_group, ic_group, kh, kw, 64, 128)|读取一次weight，读取两次ifmap，做两次计算并累加|
|34|i8 x i4, non_uniform, pvsq|64|(ic_group x 2, h, w, 64)|(oc_group, ic_group, kh, kw, 64, 128)|读取一次weight，读取两次ifmap，做两次计算并累加|
|35|i8 x i4, non_uniform, outlier|64|(ic_group x 2, h, w, 64)|(oc_group, ic_group, kh, kw, 64, 128)|读取一次weight，读取两次ifmap，做两次计算并累加|
|36|i8 x i4, non_uniform, outlier, sparse|64|(ic_group x 2, h, w, 64 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 128)|读取一次weight，读取两次ifmap，做两次计算并累加|
|37|i4 x fp|32|(ic_group, h, w, 128)|(oc_group, ic_group x 4, kh, kw, 64, 32)|读取一次ifmap，读取四次weight，做四次计算并累加|
|38|i4 x bf|32|(ic_group, h, w, 128)|(oc_group, ic_group x 4, kh, kw, 64, 32)|读取一次ifmap，读取四次weight，做四次计算并累加|
|39|i4 x i8|64|(ic_group, h, w, 128)|(oc_group, ic_group, kh, kw, 64, 64)|读取一次ifmap，读取两次weight，做两次计算并累加|
|40|i4 x i4|128|(ic_group, h, w, 128)|(oc_group, ic_group, kh, kw, 64, 128)|-|
|41|i4 x fp, sparse|32|(ic_group, h, w, 128 x sparse_ratio)|(oc_group, ic_group x 4, kh, kw, 64, 32)|读取一次ifmap，读取四次weight，做四次计算并累加|
|42|i4 x bf, sparse|32|(ic_group, h, w, 128 x sparse_ratio)|(oc_group, ic_group x 4, kh, kw, 64, 32)|读取一次ifmap，读取四次weight，做四次计算并累加|
|43|i4 x i8, sparse|64|(ic_group, h, w, 128 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 64)|读取一次ifmap，读取两次weight，做两次计算并累加|
|44|i4 x i4, sparse|128|(ic_group, h, w, 128 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 128)|-|
|45|i4 x i8, pvsq|64|(ic_group, h, w, 128)|(oc_group, ic_group, kh, kw, 64, 64)|读取一次ifmap，读取两次weight，做两次计算并累加|
|46|i4 x i4, pvsq|128|(ic_group, h, w, 128)|(oc_group, ic_group, kh, kw, 64, 128)|-|
|47|i4 x i8, pvsq, sparse|64|(ic_group, h, w, 128 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 64)|读取一次ifmap，读取两次weight，做两次计算并累加|
|48|i4 x i4, pvsq, sparse|128|(ic_group, h, w, 128 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 128)|-|
|49|i4 x i8, outlier|64|(ic_group, h, w, 128)|(oc_group, ic_group, kh, kw, 64, 64)|读取一次ifmap，读取两次weight，做两次计算并累加|
|50|i4 x i4, outlier|128|(ic_group, h, w, 128)|(oc_group, ic_group, kh, kw, 64, 128)|-|
|51|i4 x i8, outlier, sparse|64|(ic_group, h, w, 128 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 64)|读取一次ifmap，读取两次weight，做两次计算并累加|
|52|i4 x i4, outlier, sparse|128|(ic_group, h, w, 128 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 128)|-|
|53|i4 x i4, non_uniform|128|(ic_group, h, w, 128)|(oc_group, ic_group, kh, kw, 64, 128)|-|
|54|i4 x i4, non_uniform, pvsq|128|(ic_group, h, w, 128)|(oc_group, ic_group, kh, kw, 64, 128)|-|
|55|i4 x i4, non_uniform, outlier|128|(ic_group, h, w, 128)|(oc_group, ic_group, kh, kw, 64, 128)|-|
|56|i4 x i4, non_uniform, outlier, sparse|128|(ic_group, h, w, 128 x sparse_ratio)|(oc_group, ic_group, kh, kw, 64, 128)|-|
 