import scipy.interpolate  
import numpy as np

class Interpolate(object):
    """ A transform to interpolate the data, using B-splines
    Args:
        interpolateFactor: The desired scale for the number of samples to interpolate to 
        smoothingFactor: The factor of smoothing to apply to the data """
    def __init__(self, interpolateFactor, smoothingFactor):
        self.interpolateScale = interpolateFactor
        self.smoothingFactor = smoothingFactor

    
    def __call__(self, data):
        newData = []
        # print(data)
        for i in range(len(data)):
            x = [(i * self.interpolateScale) for i in range(len(data[i]))] 

            # make a spline function fit the data
            spl = scipy.interpolate.make_splrep(x, data[i], s = self.smoothingFactor)
            interpolatedData = [spl(i) if abs(spl(i)) < 25 else 25 for i in range(len(data[i]) * self.interpolateScale)]
            # print(interpolatedData)
            newData.append(interpolatedData)
        
        newData = np.asarray(newData, dtype=np.float32)
        return newData

    
