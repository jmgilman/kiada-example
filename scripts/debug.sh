#!/usr/bin/env bash

kubectl run -i --tty --rm debug --image=ubuntu --restart=Never -- bash
