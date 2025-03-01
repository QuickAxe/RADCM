from .models import *
import torch 
from .transforms import Interpolate
from copy import deepcopy

def predictAnomalyClass(anomalyData):
    '''
    Predict the class of an anomaly
    #### Args:
    anomalyData: A list of anomalies
    #### Returns: A list of tuples of predicted classes of each anomaly in the list, along with it's confidence value
    '''    
    device = torch.device("cuda" if torch.cuda.is_available() else ("mps" if torch.mps.is_available() else "cpu"))
    
    # use the cnn5 model for now
    model = Cnn5(2)

    model.load_state_dict(torch.load("./cnn5_Carlos75_70.pt", weights_only=True))
    model.eval()
    model = model.to(device)

    # the shape of anomalyData will be (no of anomalies, 200, 3)
    # do some reshaping stuff to make the shape of the input match the model input requirement 
    anomalyData = torch.tensor(anomalyData, dtype=torch.float32, device=device)

    # transpose it from (no of anomalies, 200, 3) => (no of anomalies, 3, 200)
    anomalyData = torch.transpose(anomalyData, 1, 0)

    # run interpolation to match model input shape 
    interpolateTransform = Interpolate(interpolateFactor=5, smoothingFactor=0)

    tempList = []
    for anomaly in anomalyData:

        temp = interpolateTransform(anomaly)
        # add an empty dim for the number of channels, to make it match the model input shape
        temp = temp[None, :, :]

        tempList.append(deepcopy(temp))
    
    # should be of shape (no of anomalies, None, 3, 1000)
    # ! verify please at some point ... I'm in no mood to make a mock json to test this now
    anomalyData = deepcopy(tempList)

    # run inference on the model, FINALLY
    outputs = model(anomalyData)

    # these outputs are the raw logits, and need to be... softmaxed 

    for i in range(len(outputs)):
        
        temp = outputs[i]
        temp = torch.softmax(temp)
        index = torch.argmax(temp)
        outputs[i] = (index, temp[index])
    
    return outputs











