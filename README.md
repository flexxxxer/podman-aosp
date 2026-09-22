# Why?

I couldn't find an existing working way to deploy an interactive AOSP development, build, and testing environment. Specifically, with working ASfP (Android Studio for Platform) and emulator. The existing solutions come down to:
- docker (thanks, no, podman is more secure)
- docker with privileged container deployment (hell no)
- podman with privileged container deployment (hell no)

None of the options above satisfied my demands, so I made my own. My deployment method is also compatible with SELinux, meaning:
- you don't need to make SELinux inactive, that's is a bad idea because SELinux [provides fine-grained access control and reduces vulnerability to privilege escalation attacks](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/6/html/security-enhanced_linux/chap-Security-Enhanced_Linux-Introduction#sect-Security-Enhanced_Linux-Introduction-Benefits_of_running_SELinux)
- you don't need to make container privileged, which is a bad idea because this way the privileged container [turns off the security features that isolate the container from the host: dropped capabilities, limited devices, read-only mount points, SELinux separation, and Seccomp filters are all disabled](https://docs.podman.io/en/v4.3/markdown/options/privileged.html)
- you still can use my deployment method in environments without SELinux and AppArmor

# Get started

## Requirements

- [podman](https://podman.io) with `crun` backend (default in most distros)
- for SELinux-powered distros: [udica](https://github.com/containers/udica) in order to [generate policy for a container deployment](https://www.redhat.com/en/blog/generate-selinux-policies-containers-with-udica)
  - on Fedora just install `udica` package
  - exact steps will be covered below

## Clone repo

```bash
git clone https://github.com/flexxxxer/podman-aosp && cd podman-aosp
```

## Build image

```bash
podman build --squash \
  -t localhost/aosp-dev:latest \
  -f Containerfiles/full.Containerfile
```

## Deploy

It depends on your GPU vendor:
- For Intel GPUs:
  ```bash
  envsubst '${XDG_RUNTIME_DIR} ${XAUTHORITY} ${WAYLAND_DISPLAY} ${DISPLAY}' < pods/full.intel-gpu.yaml | podman kube play --replace --no-pod-prefix -
  ```
- For AMD GPUs:
  ```bash
  envsubst '${XDG_RUNTIME_DIR} ${XAUTHORITY} ${WAYLAND_DISPLAY} ${DISPLAY}' < pods/full.amd-gpu.yaml | podman kube play --replace --no-pod-prefix -
  ```

## SELinux policy

See [notes/selinux.md](https://github.com/flexxxxer/podman-aosp/blob/master/notes/selinux.md) if your host OS uses SELinux; otherwise, skip this step

## Enter into interactive shell

```bash
podman exec -it aosp-dev bash
```

And use your favorite ASfP (Android Studio for Platform) via `~$ asfp` as well as `repo` :)

## Undeploy

For Intel GPUs:

```bash
envsubst '${XDG_RUNTIME_DIR} ${XAUTHORITY} ${WAYLAND_DISPLAY} ${DISPLAY}' < pods/full.intel-gpu.yaml | podman kube down -
```

For AMD GPUs:

```bash
envsubst '${XDG_RUNTIME_DIR} ${XAUTHORITY} ${WAYLAND_DISPLAY} ${DISPLAY}' < pods/full.amd-gpu.yaml | podman kube down -
```

Don't forget about [removing SELinux policy](https://github.com/flexxxxer/podman-aosp/blob/master/notes/selinux.md#remove-selinux-policy) if you created one.

### Tested

Host OSs:
- Fedora 44
- ArchLinux
