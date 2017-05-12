(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -ev

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# Pull the latest Docker images from Docker Hub.
docker-compose pull
docker pull hyperledger/fabric-baseimage:x86_64-0.1.0
docker tag hyperledger/fabric-baseimage:x86_64-0.1.0 hyperledger/fabric-baseimage:latest

# Kill and remove any running Docker containers.
docker-compose -p composer kill
docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
docker ps -aq | xargs docker rm -f

# Start all Docker containers.
docker-compose -p composer up -d

# Wait for the Docker containers to start and initialize.
sleep 10

# Open the playground in a web browser.
if [ "$(uname)" = "Darwin" ]
then
  open http://localhost:8080
fi

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� -�Y �[o�0�yx�@� �21��K�AI`�S��&�Ҳ��}v� !a]�j�$�$r9�o���c��"M;�� B��������u�]��
�;C�$�&J�Е�ӕj�*�b�J�$�-@-&V��Ӻ���))"|�/�g")�Q$��!oE}$�� س�H�m����5"�{kE���)��zf��Z���	J1z�F����� h�ƥ������l�O1	|��A4��k���rh���lp��Q?&	�d�m=�w�\�Ԟ��k1��7E+�h�F�&2�X�]0�E�&1����U�s5s0iP�CA��Z���&b4W'3����In�۩E�$��N��[�)�x<��M.����Ÿ��Q�&��1�<1!�����U�����x�^��l��mbܕ��J���B��(6K�;��W���]��ڷ$\����C�!
ݖ��h�6hD.B!�~�ˀ8�C&~�4p�f�*�|���s����_�f�Z�5	ߩl�+�J�٥Q��|��[��Cu:WuZš:���e�i� ���	���>�cz��Ip�]�傂j6��-y�Ϸ<D�����A�Mp�>����Ā�lH�n/���p7s����K���d��&��>���>�6A�
�ܨ<�.��Cv�)l�5	m����<��v̱��E)��6YUꥪ��n��b���Y�%A(���� *H�so�煺��[���B~Mȣ�]|�>��鯞����*���p8���p8���p8���p8�����B (  