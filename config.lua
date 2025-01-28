FS = {}

-- need help configuring anything? or just want to check out our other scripts and upcoming releases? 
-- join our discord! https://discord.gg/3UxGsTbUZG

FS.discordWebhook = "https://discordapp.com/api/webhooks/1329490327093903380/ohdF9Y6LFY-Rh10yY5LrqYikoFG2ME1JrH24dR1Hx9ByZIgN7e2V6-UMAABWkLwH1UeF" -- Discord webhook for logging


FS.moneyItem = "money" 
FS.carDeposit = {
    enabled = true,
    amount = 1000
}

FS.vehicleLocation = {
    x = 58.5331,
    y = -791.1454,
    z = 31.5654,
    heading = 80.0,
}

FS.depotlocation = {
    x = 55.4698,
    y = -799.3972,
    z = 31.5852,
    blipEnabled = true,
}

FS.rewardPerDelivery = {
    xp = {
        min = 10,
        max = 20
    },
    money = {
        min = 10,
        max = 20
    }
}

FS.levels = {
    {
        level = 1,
        xp = 0,
        rewardmultiplier = 1,
    },
    {
        level = 2,
        xp = 100,
        rewardmultiplier = 1.1,
    },
    {
        level = 3,
        xp = 250,
        rewardmultiplier = 1.2,
    },
    {
        level = 4,
        xp = 400,
        rewardmultiplier = 1.3,
    },
    {
        level = 5,
        xp = 650,
        rewardmultiplier = 1.4,
    }
}

FS.deliveryVehicles = {
    {
        name = "Moped",
        model = "faggio",
        level = 1
    },
    {
        name = "Van",
        model = "bison",
        level = 2
    },
    {
        name = "Car",
        model = "blista",
        level = 3
    }
}

FS.restaurants = {
    {
        name = "Lucky plucker",
        x = -585.6378,
        y =  -872.1454,
        z = 25.89
    },
    {
        name = "Cluckin' Bell",
        x = 81.57,
        y = 275.03,
        z = 110.21
    },
    {
        name = "Pizza Stack",
        x = -1560.59,
        y = -949.81,
        z = 13.01
    }
}

FS.deliveryPoints = {
    {
        x = -960.8378,
        y =  -941.38,
        z = 2.14,
        current = false,
    },
    {
        x = 773.59,
        y = -149.62,
        z = 75.65,
        current = false,
    }

}