clf

L_ring=969;

plot(result(:,2)/corMeanPix(2).*L_ring, '-o')
set( gca, 'YScale', 'log' );

