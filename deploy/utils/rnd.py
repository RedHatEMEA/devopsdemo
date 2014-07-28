#!/usr/bin/python

import string
import random

print ''.join(random.choice(string.ascii_uppercase) for _ in range(6))
