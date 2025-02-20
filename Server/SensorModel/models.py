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


class Cnn5(nn.Module):

    def __init__(self, numClasses):
        super(Cnn5, self).__init__()
        self.cnnPart = nn.Sequential(
            nn.Conv2d(in_channels=1, out_channels=32, kernel_size=3, padding="same"),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=(3, 3), padding=(1, 0), stride=(1, 2)),
            nn.Dropout(p=0.33),
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

        self.linearPart = nn.Sequential(
            # shape of output up to here is [batchSize,64, 3, 61]
            nn.Flatten(),
            nn.Linear(in_features=11712, out_features=256),
            nn.ReLU(),
            nn.Dropout(p=0.5),
            nn.Linear(in_features=256, out_features=numClasses),
            # nn.Softmax(),
        )

    def forward(self, x):

        out = self.cnnPart(x)

        # print(out.shape) => torch.Size([2, 64, 3, 61])
        out = self.linearPart(out)

        return out

class Cnn5_10x(nn.Module):

    def __init__(self, numClasses):
        super(Cnn5_10x, self).__init__()
        self.cnnPart = nn.Sequential(
            nn.Conv2d(in_channels=1, out_channels=32, kernel_size=3, padding="same"),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=(3, 3), padding=(1, 0), stride=(1, 2)),
            nn.Dropout(p=0.33),
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

        self.linearPart = nn.Sequential(
            # shape of output up to here is [batchSize,64, 3, 61]
            nn.Flatten(),
            nn.Linear(in_features=23808, out_features=256),
            nn.ReLU(),
            nn.Dropout(p=0.5),
            nn.Linear(in_features=256, out_features=numClasses),
            # nn.Softmax(),
        )

    def forward(self, x):

        out = self.cnnPart(x)

        # print(out.shape) => torch.Size([2, 64, 3, 61])
        out = self.linearPart(out)

        return out


class CnnBigger(nn.Module):

    def __init__(self, numClasses):
        """ A Bigger CNN only based model, Input should be of shape (nBatches, features, seqLength)
            ### ARGS:
            numClasses: The number of classes the Model has to classify """
        super(CnnBigger, self).__init__()
        self.cnnPart = nn.Sequential(
            nn.Conv2d(in_channels=1, out_channels=32, kernel_size=3, padding="same"),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=(3, 3), padding=(1, 0), stride=(1, 2)),
            nn.Dropout(p=0.33),
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

        self.linearPart = nn.Sequential(
            # shape of output up to here is [batchSize,64, 3, 61]
            nn.Flatten(),
            nn.Linear(in_features=11712, out_features=16384),
            nn.ReLU(),
            nn.Dropout(p=0.33),
            nn.Linear(in_features=16384, out_features=1024),
            nn.ReLU(),
            nn.Dropout(p=0.5),
            nn.Linear(in_features=1024, out_features=numClasses),
            # nn.Softmax(),
        )

    def forward(self, x):

        out = self.cnnPart(x)
        # print(out.shape) => torch.Size([2, 64, 3, 61])
        out = self.linearPart(out)
        return out


# # # # todo remove later:
# import torch

# model = CnnBigger(numClasses=3)
# # print(model)

# y = torch.rand(2, 1, 3, 1000)
# print(model(y))
