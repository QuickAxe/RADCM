from torch import nn


class CnnLSTM(nn.Module):

    def __init__(self, hiddenSize, numLayers, numClasses):
        super(CnnLSTM, self).__init__()
        self.cnn = nn.Sequential(
            nn.Conv2d(in_channels=1, out_channels=32, kernel_size=3, padding="same"),
            nn.ReLU(),
            # kernel size here is (height, width), so we're essentially,
            # hopefully, converting each of
            # the 3 components (x, y, z) of the accel and gyro values into one
            nn.AvgPool2d(kernel_size=(3, 3), padding=0, stride=(1, 2)),
            nn.Conv2d(
                in_channels=32, out_channels=64, kernel_size=(1, 3), padding="same"
            ),
            nn.ReLU(),
            # nn.AvgPool2d(kernel_size=2),
        )

        # needs input of dimensions: (batch_size, seq_len, input_size)
        self.lstm = nn.LSTM(
            input_size=64,
            hidden_size=hiddenSize,
            num_layers=numLayers,
            batch_first=True,
            bidirectional=False,
        )

        # final neural net to classify it
        self.fullyConnected = nn.Linear(hiddenSize, numClasses)
        self.softmax = nn.Softmax()

    def forward(self, x):

        # print(x.shape)

        # x = torch.
        out = self.cnn(x)

        # print("before view", out.shape)

        #! not sure about below code, need to check the shape of the tensor that the cnn layer spits out

        out = out.view(out.shape[0], out.shape[-1], out.shape[1])
        # print("after view", out.shape)

        # lstm takes input of shape (batch_size, seq_len, input_size)
        # should be something like (32, 99, 64) #!bound to change later

        # print("before lstm layer", out.shape)
        out, (ht, ct) = self.lstm(out)
        # print("after lstm layer", out.shape)

        out = out[:, -1]
        # print("before nn layer", out.shape)
        # print(out)
        out = self.fullyConnected(out)
        out = self.softmax(out)
        return out


# todo remove later:
model = CnnLSTM(hiddenSize=30, numLayers=30, numClasses=6)
print(model)
