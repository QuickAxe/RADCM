from torch import nn


class CnnLSTM(nn.Module):

    def __init__(self, hiddenSize, numLayers, numClasses):
        super(CnnLSTM, self).__init__()
        self.cnn = nn.Sequential(nn.Conv2d(in_channels=1, out_channels=32, kernel_size=3, padding=1),
                                 nn.ReLU(),
                                 # kernal size here is (height, width), so we're essentially, hopefully converting each of
                                 # the 3 components (x, y, z) of the accel and gyro values into one
                                 nn.AvgPool2d(kernel_size=(3, 2)),
                                 nn.Conv2d(in_channels=32, out_channels=64,
                                           kernel_size=3, padding=1),
                                 nn.ReLU(),
                                 nn.AvgPool2d(kernel_size=2))

        # needs input of dimensions: (batch_size, seq_len, input_size)
        self.lstm = nn.LSTM(input_size=64, hidden_size=hiddenSize,
                            num_layers=numLayers, batch_first=True, bidirectional=True)

        # final neural net to classify it
        self.fc = nn.Linear(hiddenSize, numClasses)
        self.softmax = nn.Softmax()

    def forward(self, x):
        out = self.cnn(x)

        #! not sure about below code, need to check the shape of  the tensor that the cnn layer spits out
        # lstm takes input of shape (batch_size, seq_len, input_size)
        out = out.permute(0, 2, 1)
        out, _ = self.lstm(out)
        out = self.fc(out[:, -1, :])
        return out


# todo remove later:
model = CnnLSTM(hiddenSize=30, numLayers=30, numClasses=6)
print(model)
