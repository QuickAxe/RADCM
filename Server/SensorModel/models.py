from torch import nn


class CnnLSTM(nn.Module):

    def __init__(self, hiddenSize, numLayers, numClasses):
        super(CnnLSTM, self).__init__()
        self.cnn = nn.Sequential(
            nn.Conv2d(in_channels=1, out_channels=32, kernel_size=3, padding="same"),
            nn.LeakyReLU(),
            nn.BatchNorm2d(32),
            # kernel size here is (height, width), so we're essentially,
            # hopefully, converting each of
            # the 3 components (x, y, z) of the accel and gyro values into one
            nn.AvgPool2d(kernel_size=(3, 3), padding=0, stride=(1, 2)),
            nn.Dropout(p=0.33),
            nn.Conv2d(
                in_channels=32, out_channels=64, kernel_size=(1, 3), padding="same"
            ),
            nn.LeakyReLU(),
            nn.Dropout(p=0.21),
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

        self.dropout = nn.Dropout(p=0.33)

        # final neural net to classify it
        self.fullyConnected = nn.Linear(hiddenSize, numClasses)
        # self.softmax = nn.Softmax(dim=1)

    def forward(self, x):

        # print(x.shape)

        # x = torch.
        out = self.cnn(x)

        # print("before change", out.shape)

        # before view torch.Size([64, 64, 1, 499])
        # after view torch.Size([64, 499, 64])

        # out1 = out.view(out.shape[0], out.shape[-1], out.shape[1])
        out = out.squeeze()
        out = out.transpose(1, 2)
        # print("after change", out.shape)
        # print(out1 == out)

        # lstm takes input of shape (batch_size, seq_len, input_size)
        # should be something like (32, 99, 64) #!bound to change later

        # print("before lstm layer", out.shape)
        out, (ht, ct) = self.lstm(out)
        # print("after lstm layer", out.shape)

        out = out[:, -1]

        out = self.dropout(out)
        # print("before nn layer", out.shape)
        # print(out)
        out = self.fullyConnected(out)
        # out = self.softmax(out)
        return out


class CnnSmol(nn.Module):

    def __init__(self, hiddenSize, numLayers, numClasses):
        super(CnnLSTM, self).__init__()
        self.cnn = nn.Sequential(
            nn.Conv2d(in_channels=1, out_channels=32, kernel_size=3, padding="same"),
            nn.ReLU(),
            # nn.BatchNorm2d(32),
            # kernel size here is (height, width), so we're essentially,
            # hopefully, converting each of
            # the 3 components (x, y, z) of the accel and gyro values into one
            nn.MaxPool2d(kernel_size=(3, 3), padding=(1, 0), stride=(1, 2)),
            nn.Dropout(p=0.33),
            # ================================================
            nn.Conv2d(in_channels=32, out_channels=64, kernel_size=3, padding="same"),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=(3, 3), padding=(1, 0), stride=(1, 2)),
            nn.Dropout(p=0.33),
            nn.Conv2d(in_channels=64, out_channels=64, kernel_size=3, padding="same"),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=(3, 3), padding=(1, 0), stride=(1, 2)),
            nn.Dropout(p=0.33),
            nn.Conv2d(in_channels=64, out_channels=64, kernel_size=3, padding="same"),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=(3, 3), padding=(1, 0), stride=(1, 2)),
            nn.Dropout(p=0.33),
        )

        # final neural net to classify it
        self.fullyConnected = nn.Linear(hiddenSize, numClasses)
        # self.softmax = nn.Softmax(dim=1)

    def forward(self, x):

        out = self.cnn(x)
        out = self.fullyConnected(out)
        # out = self.softmax(out)
        return out


# # todo remove later:
# model = CnnLSTM(hiddenSize=30, numLayers=30, numClasses=6)
# print(model)
