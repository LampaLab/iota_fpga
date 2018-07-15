import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

d = pd.read_csv('pow_delays.csv')
pow_delays = d['POWdelay']

plt.hist(pow_delays, 100, facecolor='blue', alpha=0.5)
plt.xlabel("POW delay, sec")
plt.title('Average POW delay: %f sec' % np.mean(pow_delays))
plt.show()
