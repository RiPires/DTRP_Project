import matplotlib.pyplot as plt
import numpy as np
from scipy import integrate
import sympy as sp
import math

def normalizing_values(list):
  normalized_list = []
  minimum = min(list)
  maximum = max(list)
  for i in range(len(list)):
    normalized_value = (list[i]-minimum)/(maximum-minimum)
    normalized_list.append(normalized_value)
  return normalized_list

def percentage(list): 
  new_list = []
  for i in range(len(list)):
    new_value = list[i]*100
    new_list.append(new_value)
  return new_list

def SR(D, T, tau, d, alpha, beta, gamma, delta, K_50_K_0, sigma_k_K0):
    x = sp.symbols('x')
    denominator = sigma_k_K0
    print('Im HERE')
    print('gamma = ', gamma)
    print('(30 * tau - T) = ', str((30 * tau - T)))
    print((gamma * (30 * tau - T)) ** delta)
    print('d  = ', denominator)
    p = alpha * (1 + d * beta/alpha )*D - gamma*T - ((gamma * (30 * tau - T)) ** delta)
    print('p = ', p)
    print('And now HERE')
    if not math.isnan(p):
#      numerator = np.exp(-(p)) - K_50_K_0
      numerator = np.exp(-alpha*(1+d*beta/alpha)*D) * np.exp(gamma*T * (np.exp((gamma*(tau-T))**delta))/denominator) - K_50_K_0/denominator
      #print('n = ', numerator)
      if not math.isnan(numerator):
        sqrt_arg = numerator #/ denominator
        if sqrt_arg >= 0:
            t = sqrt_arg  #!!!   PORQUÊ RAIZ(2)?   !!!#
            #integral = sp.integrate(sp.exp(-x**2 / 2), (x, float('-inf'), float(t)))
            integral, _ = integrate.quad(lambda x: np.exp(-x ** 2 / 2), float('-inf'), t)
            pre_result = (1/np.sqrt(2*np.pi))*integral #!!!   FALTA UM PI DENTRO DA RAIZ   !!!#
            result = 1 - pre_result
            return result
        else:
            return float('NaN')
      else:
        return float('NaN')
    else:
        return float('NaN')


tau_points = np.linspace(1, 70, 71)
print(tau_points)
N_values = [128, 35, 83, 51, 24]  # N - number of patients
d_values = [4.88, 1.5, 1.8, 1.8, 1.8]  # d - dose per fraction Gy/fx
D_values = [53.6, 61.5, 55, 45, 32.5]  # D - prescription dose Gy
T_day_values = [28, 42, 37, 37, 37]  # T_day - treatment time in days
v = [2.04, 0.009, 0.00065, 0.0053, 0.64, 0.21]
K_50_K_0 = v[0]
alpha = v[1]
beta = v[2]
gamma = v[3]
sigma_k_K0 = v[4]
delta = v[5]


# plots

# Liang
D = D_values[0]
d = d_values[0]
T = T_day_values[0]
SR_plot = []
tau_plot = []
for i in range(len(tau_points)):
    tau = tau_points[i]
    print('This is the step:', i+1)
    sr = SR(D, T, tau, d, alpha, beta, gamma, delta, K_50_K_0, sigma_k_K0)
    if not math.isnan(sr):
        SR_plot.append(sr)
        tau_plot.append(tau)

#SR_plot = percentage(normalizing_values(SR_plot))
plt.plot(tau_plot, SR_plot, color='pink', label='Liang')

# Dawson
D = D_values[1]
d = d_values[1]
T = T_day_values[1]
SR_plot = []
tau_plot = []
for i in range(0, len(tau_points), 1):
    tau = tau_points[i]
    print()
    print('tau = ', tau)
    print('This is the step:', i+1)
    sr = SR(D, T, tau, d, alpha, beta, gamma, delta, K_50_K_0, sigma_k_K0)
    print('SR = ', sr)
    if not math.isnan(sr):
        SR_plot.append(sr)
        tau_plot.append(tau)

#SR_plot = percentage(normalizing_values(SR_plot))
plt.plot(tau_plot, SR_plot, color='blue', label='Dawson')
plt.legend()
plt.show()

###
#term = (gamma * (tau - T))**delta
points = np.linspace(1, 100, 1000)
x_points = []
y1_points = []
y2_points = []
for x in points:
  #y1_points.append((gamma * (x - T))**delta)
  y2_points.append(gamma * (x ** delta - delta * x ** (delta - 1) * T + T ** delta))
 
  x_points.append(x)

plt.plot(x_points, y2_points)
plt.show()

