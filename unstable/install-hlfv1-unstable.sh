ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
export FABRIC_VERSION=hlfv11
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv11/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� B�4Z �=KlIv�lv��A�'3�X��R��dw�'ң��I�L��(ydǫivɖ�������^�%�I	0� � �9�l� 2��r�%A�yU�$�eɶ,g`0V���{�^�_}�G5�lG�k��X�<hۦg��AW�t>���J%��xZ�i��KB\�/&��%^H���%ğ���qe�K�-j��p��C�!��4��x��lj
v����v��/Õ5�{����Q+mԺr�:�:V�؎�*EA-�v�����/�Y��u��nϴh��[����]l�>�6���˽iY~KKnښQ�a�L>hC��iO��'�?���'y�?!$�K(y��(o��Ϙ"w��G��9Р�<y���A�'Ÿ(R��N�s�e�XS3bM��p���
F�HQ�U�����9ik}oks��/>�?��at��z*<��tSV���q��R}�%�p���E���(�l���� |�#YM�ꛖ�7�̰˶j�I�4;|U/p����J�_L�|2��<Q�an�R���-"b����I!r;��4�F�P����!�J�l�04�=N
n��qM��M�)�U���*U!d9(��&���#b�U�����wJR;�tL� z7q���&~�b��1��u�*2
�O��ki@\�$.��'R��Aɟ���E!���gD��#�A��,�A��zP�$�@�̪c�}�'�v:�������UӦ�f6;2G��0L�ɠ�q��X�@u$�����Vr��)2}@��.� ���vI+�V4�����‮�i.�DxWMx���[�pUǲ���u����є2-:9��0���T9�5D��þ�1*�2bᛜ�h`@8#��#xtb�`����%
�k�&p�����6���NQ2��9ށ�p���~=vd�SM����Zf���5����_ũ�?��������7=�yy�2���syN4N�!���^L��)�����1��I|�u��b�eٙ�ؚ��~32=��٦KrHv�l��r4϶	p�����{ٍ��ziko+_/U+��k�~7>������������g�	K4W�A��*����N��Uڬ��?g�~�;�4y���ې�;^���C!�}�q�&;���f�;�d�����/M6�d�r�߭�To�5J���v�d�'�f�.$��d���cC��"$�HZh��?x�G2�o-]'��G��#�4��ʏВ����h�"��剬fQ2q^���0���x�f�H }�LN�@' |��6�|�4ډ���@Zy������f�KV`Q�wL�\h��ĉ������iH �	���������_��Ʌ�{gQ��2�o�v�����Q>*�Z�̨��u�C�@[�Ј�ғ�Y�P��4����s��"˳��Oز�C�%����i���]#�j�Rgv��+�۬ʳuR�q]���b���Q���fR���;Q��?��d��6X` �Ɵ�)�.��l:8"Fy�t�=�Vh{�X
r��M�@�Ț1�qLݣ{�������mz��Fd[�h�ء�tE"�OK�1�2m��
���@�laCņ�� NI0� �D�!7�6�>�X�M��6���-���a�-�>����߬���7���s�e�������:������T2���E�����e��+6�����-�]��C6�j��l��?��K���|�/�����.'��p�[�M��|p����ޓ�/�����)�o��Vݿ�l6�Y4S��.��-+Ц��mv�!�Q!�6��͎Eh�dΫ̰���W������|2>��}����G\«��i�ߟ>'/�����������r����N��|�ڿ V� �D��N��.�L��-�cX�@-�v\�m۴o#��׿��ʆ�D9r����m|�&z�-�3�����dQtJsУ��~�C!:�8|��&�*�VD ��m��6�E7���Dؐ��M0��&�����؋}�k�3ؚ eg��8�*�ޓ�Gp:l��I`��Ei��'���-,���Ϲ���t�n�$�����Reus�cњ��L�"���D](��7ŉ~�����Z.�@/pg-��F���@޶���]�
1Bt����b���*=_"O��9��__�ܣ�`���k��1bwj�'r]��o�{���ŕс��P/�N��
&/���5^�7�I�C%�D�E�(Ңo�������x��D�=Y;���p�4���b��Hgts^�����mȻ?�*�'�lJ�zƧ��G��"	C�o�<C�e�݈�ֈa2ht�?��0G����� O��f�0�����q+Ȃ�5���̲�/���K1���)�,d�<�(��I��`fb�U�N����v��cc:��	��L�8�%`щQ�߬��EP��V5�YY-�U����1&�����i�"�;M� ��$�}�n�9=�(=�~q[���鮰Wy�T�k����
x�n�M·��9�{�[���������L���xBL��(���-�-x"���r���'	����o�r��'Qn�KI��({)h�s-�;�R}�'�1K�tD�
Q���z���i���z)�8|��~{)���t��̮oZ�協3��Q^��4θ�C��iQ$��O��.�������@>����W�S����DR�����K,��Z��R��l+�$�uR�:�z�F�E쫅�"�٭�HI����4Fh|��H$�-�s�����_T�Z-Ls���-��v-砮<@MX�ҵ��: LVcP�XX!��� K�!q�[������mL^�6uB���又}t	�no�8���h�/&!��g'��>�$�>�[
�sH���ݖ�Hf�kM�CL�� 8j��i��ם�2�qp�)GT��İ�l���Dv��dY��Pj3Dh}i� ��K��0�@v����7:���� �4P	���H��@GYG5MWÎ�6{O�u���ƴ�����4#��E_��O����
ݠ����d����sȎa͡ ��(B%9��Ud`�YdP��U�F�_�����;��ع�\�ȶ٢2���hkL�lί�0�E��O�]�ap|��W���1=� >�E[Y�%� L��"A�M�<��T������
�u��:�J�8�}Z*�P P�,h6��E\����{t;����18#"�3B�P�; �5#(f�8+Clj+Ȑ����EL��5w@g-�'8rdK�
�UE�d=��&`,˹b�O��q��M'�//=�mabg��p'�>k��l�'��.w
d(�&w9�<�b�ibt��l"U����"h�cL�=�6�Ւ6jÃf�m���?������@ f�P�=z���:�k�2��f����ae ��<41�w'�Eк��6f�Nb[���k�8�|��Y���c�M��\@�,��� ?6�u3m�lR`��2b�tz�g�p��h�2��#�~?P�ը1����Y�Ff�X�<��;n���P�tz�H�<�x)%ys��]����:���'�(F[RU;XB���!�9��oh]lz.�W����t�zt��� m����j���2B":�ط�#L�,��7�xvDht�e� ��ZUvb0BNqLD��ʬ/���]��u��,���v�v�:7��c�	|��Ԥ/�aJ67pA�LV���t���p�=rʹ�.��zlk��R�,���]�O(��3˨�rW�ٗ��سF������?�s!p27>���}�$kcu�h�&�L�ͺ��1�X IAD�D6��d�s�y@�0�k�k
����*8� n�X�జ "v�p���T�ҳN�t's�!�)7-��(}�5��3��S��05��|��'`NS���Fb"9��i/N��@�>�����~c2S>w�8q�bB���+Dtm֊�uMvp�g�����y���c�ߧ�8��>����������B
���p{��+�\}��?��/~���N���.�7y%�3�-EP�DFn5[	e9�I��1!�e�p"��43�"'2�LFh���bs9���;�O�����or��0ą�p�D�2�KW�8n���0��\����տ����I$_\�ry�'�ޥ�'��Я\�V���.�=�w���?��_��QE���� �_1����{6���̳�
���tv_�y4N��O��i�O��%���/�p�(��u�g������_���7����ί�C��_��?�����o�?�/��n�=�r����W�����ȱ;�أ��M���q˼����T	>�H7ո���d�o��H&�����eU�dK^Έj�U����w��Ͽ�~�ɷ�i�˥�~����Wɟ~�?V�x��|�w��?Ƚؘ�퇡8��B��A�?���p�?��Uު���������}�;��I�ލ��+��*(_�7J����(�Z�\*�k�����m�W�I�R�p���Y^޾���2�8��o�ri#�n?��oVk����;*ל���vj��b����Q�QB��]���5qՑ<<T�Ik�Q|P��h[�_�l��^��p��>H�˟U��GŇ��:wʵf��Q�J�xm�U����n��(*�Ia�~��+=n6��W{|�r$����~y��,�?��n��j�:��^�珤{�ve''�6$}�Q��{E6�R�gv����̠��;��noU�m�ŞЀ!$�u�^�٭X�X9,�z�=
�Q��`�J�~w'��@�5׶�]1���Z���b�������z�+�v�7̇��}>/�vK�sA�)�Z[*r5QH��
�έ��ƽA���҉ݏ9ŇI��x�k9[锶���ؕV7����o4����j�pKx�;�k�� &;r�U^�{�f��J��XN��o�u��2��ȧ,��q�U�C�z����{R���I�z-Q,�k�5�՟��b{]t�^Cz"?�r�%{3�:��>3�w��V�z���ۣ�ACu@Y�J���ޏ���nnW.��.��,�ɣ[���}�m%�v�6�{�|i�3]�N���[�n]Z3��C��jl��{�d�F�����;�V���Q���K�ON��5bMJ~hMu��m;�[5�[���5�x�צ��S�����t�,�S�����#��Բ��T:�5�������}i��)���i�5N鮂��G��r�!�{Wף8��G�Ѩ㝝1���N����m���+��06�`l0p���m�7�`�jr��HQns��\�_D��'	�*���������t���.���p��y�9�{z�',LQb�����F#��E�;��	�}}�j��6��OLj#WSM7��2��2�4e�J����!�c�5朔�JЉ���r�u�O����m�d��� R9U��+�P	�D��o'b�Ed��6����Qi�3L��hli���֘�)aYmS�j������v���u�^��F�*=��D�h-G�զ�����>6M�����=CH�����m-X���U��+";fY���z������27[����ۍIR���3�se��\#|�RCL!k�moTvq��c��,����e�'��NA���������2-Ȥg̭N�e���� ��b�)�ᢺ��('*Co��Uk-	�<��ۡ�i�|C�྆�0j,V�2�����y��Bv��#n{&�f���4m�L��|v�\���7p�ZCiw����>�J����C�ƞ���JR;� ��q7@����t�?��hQ�9Җhe��8�Q����2;�x?�V�cհ��b��6\AHh�Q��Ġ�L�L��F��2Y�>�S����%�Ѓ�y�!b:��=��X4%jM�ԥ�2��#}��6�4�ږ`�(���3�Ȥq!���V��{��
JNx��5hv+L���D�Y�Tg�i��4D|��'��϶j&����|6~[�ˣ%���������/>{��Խݨ��ȭ�{�+N����8;�?A��Y�p��p�������K_���-_�������������/����|ߥҋ�{�����N��e��.}�W�J��]�A�3̥����������m�_�-�˷��Ӄ��(�5G*ڷ1_�+ۦ�\����H�{��w/b�m~�_X��y�~�w��5�bB�]������f�<O�=E5�e.蚺�Dn�+��3pO�:'n��{W�@�D�L���&X��m�P9.�x���06j:w@�5zC�R�-�:�!�jֶ>df�֜!�ӯ������K�����h)%�n@�Qŷ�YU	By�th%�z&ۼf��U��
�v��H�cs&\��Ǭ�����dS2��*�]
�r<g;�ar,�lǗ�|�Lӱ--VG��~�X�,V�Ol�I��+p"�a��OZ=�A�Qg6뢈��hb�kD���G�I'q��	T�9]"�.�(<��ވ�z��vް�B���Nx�����Mz��z���Pv�BY�+�,wf��i4�J��Q�p��<�wTN>���}�\=�ݓ@f���s�∞`��*���X�k�d�M�c��1�|,��Ʃ�CO���]i�1ۿy{G�W�8�t�Ko¡�����0�B�ڊ��=m5ZX_�̍��|nxZ.O�P�,=�P�ĵ^<Hڳ���J�[���	<�X��4M�B�Ǫlr-��k�̫,�ԯ;˘��D^��5۩�"�[�Tk�m0�7e���GO���q���xIQ/B�q��m]������J˓]O�Y�3\��Ao��}9�٫�*�v��y�0�`�&���"���|�Ģ��Љ��f�:��(��契���>��i ��U�����e��pd��*I!�@�H$�&��'�8��:�J�U0��:s
&Э~c0��v�Lک�?��}<���;]��/�55Z"�"�Sk&2kQB&K��X��*ہn�&����,c�5����Q�Ng�I��P�lC�r�ӈ�Ԁ�"���4��
/s�j~HlmG�D�-\�����v���&6���{�{(6j�F�CB!ug�A�a�b&��1���A�#=ta���;��%Ʈ�l왓����2a��������)L��:�Y�ⷺ�J�?j��wt�ץ��J��E�Y7��5��d~�����oo�hۋ�ux5a�^�N|�7�/��\om�tM�җ��"��)?@q^rR�M�/�o~��G��?������C_�]�R����9v;��Я�t
�kO��������lң�R����ojv�nY�N����f���n(�|��~wu��7�zs���~t/��_�O��on��D�^B�}�2��z�\>��g�� �O���ɒҷy�w��CP
������k���;�?�"(���	>J��]P��S��0�����
�Sc1����8�w�\����J�����Cӟ}��H��'8��z���t�c��L����u���o�5Ȣ����t������B�?���
��g�����V�=]�? ��ϟ��K��?���i˼o �?����C��ȕ�]���d��'�?����'��ON(�����&H�Zzɐ�������JP�%����2H� i m�]�6������?���@��/
�9���?o�W�'X��3AA���y0�
����q
��, 2�A���@ϻ�B�?���$�Y W�O#� _ ����_!���/�?�?����U ������)���	@�-PmT�zJ���{�A!����!W�g�G�����?o�W��?7����|P���s����`���������	�꿉������?7 ����_�G/��������R�z�S����2FSC�g0�p}{����芇�������gH�C�#gPE�9�X��OE����� �?������=ڢ��b������6�$$�ӱ](�0󨃎#��7�>��j�M6�u�fl����[���6�NW���oj�W��2V�V�J{�$���xo���ڶ�S�Q-�TŘB�4���r�d�
���z�d&��T�[�wqSy�C�?���r���L� E�����"�?���r���W|u��y�E����Ç�������[��8J�z9a\om%ZL�M�����&�'�W���Pk����mdU��О9#Qxy#�n�x��]mh�����w���U��>�&��X����H� n�}(�y�������sB��ߵ_��O�S����@�Wn �_ ����/0��_^�?@�B�?���$�_x�����k�꿦���2
v�/wCI�:���_������[�*7�Х3���@np��;��"2˩����B6�A�ߌj�²����{e��a;������#�B��b�%�B��Zu�nc+uj������w�)�ǎ��T��Vg���Ӧ�B�^i9�#^7S�����p����9N���v�+-h^'��Q����UQ�0xK�wW�Aw4�|�|U6Y�=�p����.�Uu�3�M6�����fB�M;n��Wb���je_��d���CC�t��%i�����J�ݬ�l��}��.���P��@�e����>��F���������������_2A&���������������,�)��
��CV��������l �����_�������+��/#d���>/����[���1���+X������K�P�����?���`�?X������G�`������������燬���R,��?���& ����_��/�E�(	���=�ߜ �1�E�?����o&(�ӗ��`�&Ȏ�oܝ�1!w ���7�c����,�/���y�?���������d��	����s��b�_��/#��AZHȊ�ߵ������� �?��������	��Q�ܐ� ���������"��g�a���B���?0��c&x��B��qg�ee-�Q̚�\�t-0�^��������$��Sy
m���Sw�ݟ�Tޔ��r��l�U����Dk^��Q�"�S�BQ�e�Pe��a��C���oT�;��=R����ꮆSIs��F�z}�&��O�&��)���I��Э��<b�%��2���p�I�\��+�a�Q5b�sm�0���13M2:J-�Аd�����(�0ϡ����P]K������wF!���� �#��@q�<�������b�_��CF(��␙������8��� ��A�GP�������8d� ��y�B�?����P��Cf�B�0��@�GP��|�(��C	��rB��o���x�������?o�W�������?��	��]�}��]����G�'�"��|C*�G����4����94�1Rԟ�����Q�ǩK�������j�ݣ-��.�O�_���Ȫ�*q��d�s�]���ǉX�$$�ӱ]Lz@!1�8��`I���LT��q�mD�A�����׏��ͦ��澼_�0����rm��$Жx�	&�)$MH9-ܶ��v�P�J��ǇNK�Ý$�V$=���,�P�}�q���]�T�x�P����|�<��������P��?rC������60���9���_~���oim��h\uZ���C�	a[cN�Z#�j�އ�\�����(�ߓ���˥@��91��m�-Z�{C�=��N3��^�6xc�T��)9.1��6ܚ.��~�L#����o�b����/$M��������]����X��r���_ ������r�0A��$�_NxL�Y���[���Kʚo[>����wV��bY��^��� ����i5 �S"��<��$�6�T��m�e>��e�O"��O7��NFU��h�Q>1����B�{�2zks4ÛJ����n��e�85�2(k�&7����S��:��٤���<��^�z��8�Sc�tL���;��D�-��W�9.v�D@�w�=��������ӓ���L��g���I:������C���זJS~9/{�4�2y��73����{a�Wt9l��^�S�b,��zhIx�u��H��O����/��w�ь�k =ѵ���/b/H$��Be�NGK����P����9�!=������i^�Y���b��D�}w���Q1�dg��ٱ7�����.`�t�����Y���_�!�'����E��0ӫ����w��b	
���/����`����ﳞ�L�Ft��<O�Tʓ���7b��b�$IÐ	��x�����<��I0�W^������P��"~e�_[cW�H�6h����e�,�Ɖv��*{�"�'V��ٷ����ܢ�a����:<����������O�������UWP����9��H����̫�_�@�Q�H���6Ń���Ky�&!�""��L����4��l�FM	i@q!1��$xD�`?�:����/�~��k�Y*j����g�2�1ŏw�a���C�9�l��Ә��R����.W��Z�H��Z��[���'���"=�a�WMA��o�C�����_���u�����o�����{�?�w����
~���w�&���b)��(���#�W��?������}ժP�!(����a`�#��$�`���G2����{���_��?����H�Z�o`�~�2������?����:���W�^|E@�A�+��U��u��(���ǡL�A��;��x5��aH��B����,�����nu�ޔ��~���)�^)�^T�̥�i%&ߋ�T������ot�q�%Ӱ�v��c�b6W��}�;��G��⟱Ɉ�ck^ߔ��'OM;�:ks��,��L).�roT���^����}�G��������e��Vv��?tz5�Y��rz�e{|�a��fEb�$؉�����_��YZ�����m���Kw;�q�[S�km��2ً�^�9Zcb�K�mĶ<&����i`�f/[�S�W�V�%���,ue��S�W�����DŤ��7�s��{��+�ۀȋ���ъ�ٙ�[�P2��+W���w�r��������;Y/��fK��:l9�/�z&�w��қ�I�d�;	���4f]��5�-qԚ\��!�uu��<�����wDu͋�MȺ��~�3�M�*�����4���Z���C����l�j ����Z�?þ�����z��� 	�y����$�Z�a�'~��՛��~��`z��8�MI=�cn�+�����+����/����_�*���_��$~�Zbp��tҚb���KmY���\'MW�{�N�n�͟^ß_�Fs)��2>����s?�2RS��i��]M�>1��L��c�}/�(��8I6�.N���#g�gc4g�lk���#i��b4䖎�NC4�A<����9S�xk���֧������u��)�*�Ԯu��p��Z��g��sQ4o���饽0eCԥ����K�s���Xm7�A�A����6k����Ap0������T�g��x�n�ta�,&+�6t'	��	���op-�I�W��73=0����9�۹�	�4�0��CS���,�w�-��ޮ�P�����t�!�{ 	�J ����Z�?� ��?�P3��ω� 2������?�C�����u;�o|?�W�c�pi~!X���#�ϯ���J���4�'st��݊ �I �4F�|� {���5 ���E�>���i��: �`<M/}�������Dv>aQ��\/���Ƕ�#�\�aL�9-��F:K�����r�� �M�)c�?����S����6dQ�� <�:^�=�X�Z/痒��XgKjjo_M�^��#-�젴6!V4�1e���V�^OF�0;3Ծ��B��q�����-�DQ{�p�z���E},��V�.�T^yv��.ɃZ���+��_p���J ����Z�?��ʨ��C b������:�������_m��������$�(�C��H��>�%�����k�u��|0��?j��q�C<��0�#��p>�$�萏���`X>����( x.B�!�i��-q���`��D���o8��ݮd䳦0[�,���!> Ɖ������J��c�k��m���;ʅ�Y����v s�ː^�˼&F��v�3�^&�7�Hu��������#2��f�;��-�œU"��ܔa��[����VG����}�����Q����Q���?�6��w��Q��W����#�dN�}�-ۍ�����n��ڼ_���m�ڟō���?7Y���Һ4�^�%w��ϖ�����8f6��%'��ַMor��^���I������(r�LJ�2�Ck����
c��{+�x�S����:<����h�;����P��_��_���_�����*��@X���p�a����g�_�i���=��:���G�]�v1?�Rf_~���]������B���K�Jl���8{ˌj��v��5��Bز�@�l���[�v4ӵ"���q$�n6bq��GF�dƜ����^ئTaY�Y7c7�vzn`������n�}{�o3��n�|�����T�����Nʔ�t�Ӊs��~�,�#QkfY?���Pj�<q��:�tYe:�cָGz�E{F�Y MŖu�;��Vh��3I��qH��X���[��'?BC�.|C�I�3�)b-t�\'�l��7bA$�l���Fr�R�f��0������+P���� ��_E x�Ê�������P�AC�j���+���?D ���ZS@�A�����A�+���pך�J�߻�����H����������j����O8�G��V����_;�����$	��^�a�K����P�OC�?����������C�����x�)���v�W��_��V�ԉ:��G�_h������_`�˿���#���������( �_[P�����kH�u�0���G�����J��[�O��$@�?��C�?��W�1��`�+"����,�a��<��AL�	���B��<�'TƷq�E�1/$4�$��ﳨ�������O$���~/<,.��c&���3��P�O-����vH_Xˤs�I��8�p�ɔ�y0��s3_몏�l��^QRo3[��q'���[��C=z)�J�:��<R�v�@�mw�éU�?��:<��G���(@��OpPOP�����i��(����ă��p��d�m����{���A��A���A�_����*Y���Bp��i��x��1q���0��(��H�x"JX�S*��
9�OB<N�"8������!�C�����ic<[�g�|�5�k�t��LO�Y�У��"韆G�y�����fs˦�+.U�ɑY{TBv�K��s���lNL��!�Tp����l���|���t��C
��8���馹lA���������@���K���������S��GA�����i� �����W�x,T�?���� ��_�P���r�j���\����$�A�a3Du����W��̫��?"��P�T�����0�	0��?����P��0��? ��_1�`7DE�����_-��a_�?�DB����E��<����``�#~���������O�D��r�S�4{9�^�����]�j������Y���ٔ����~���}��pe�'=\&�ԑ�f����Y���6��]����F(W��(�.�YI��ů�ڈM��Dڅ<�k��,S)��=�W���X>�{�B6E�4��~.�v���_l<����j��/���T4��]H̠�=�;�\'�<YO�s��$������*>gb�=Qly8MZ�����ɾ0l�%�*b]��>#�Cs��&�`�ÍZ�/� ��@G���W�v|9�������<����G$�L�aJb�����Y��(��O0�	�?��'���U���������k������Q3�o��/�d�����u����V������Co=��)��|��re��_:�2�(]�wO?5���<)ѹ��̕�4T���;?#�Ԟ���c��^?6�T,Z���vy���Iu�����UT��_��?�NñT�f��Ik����UHk�uW/,�id�nTZs�4]�:9��6z~ͥ���h*{�e����3MQ�#{��#>�RH>�w�E\%��'�&��i��ü{��lb��̞mM���v$m�]������I`�F;��cr>�o�o8�0����rV�Ҙ���5EZ�n�u?��[-k��UwLILyE���)O^_/�)�.�v~p�$]���]��j�Y�Hz�.�YsFv���)���뭓E<Mœu[��f1Yɶ�;Ih>��HhN�~�k�L2X��r(帙�ـ1�|eu�q�ΕM��)p�6�Z?�gg��cly���7j��?a�#��-�s��w	������_��"����Z����G8K�τ4��� �	��!rQ�G�R�E$F8�C	T�'8�x7u�������#�W��/.]ߘ�fR�o���y�w�Y�B�:�ڼm��Y�������c�Y��ȑ�<�
-�ě�~�L<wy�&���3s��[@�M7�1�z�VI�c���]�s�J�RU�T*[[jǸ̶�������;ݮ�L+c7U�E�O���W��K�0�##S��V�:�5�Z=9l%[Sf��qb��9�Ѿ�Su������u���+Ͻ�;����9�KX�����+/B���<[y	�_t�m�sS㿯�����=_y����8�u݃��K�Ӡ0�D��v?_o�O.��b����+��M����3�f�ce�Jhژ����Ƈ=���F����T*W���� �ؙƥY=��y;�'�������4��'���t\+%��n�4����Z^���Y������_�q���H���%���=_Y��Z��Z��Z��Z����3��6�3�a��f��������,��N���7����[���W)Q�>����V��r#�_=���o%Ջ��5�v��������?q �g� SU���+祅�j/,�P:�����A)���13�L#}��8������D��ä~�k�w:��^囒~;h�?>�j��B����V�j�}
�۱u��p����T�D���O9����[�; �'���Q�VyP�-��)��pa������`�b��ˏ�jo+�ͱ>��QdP��j|nf:M��=9��*����xxT~[�5�����d�T�+��gQ��M�tT;��k��;�Ml��oJ��/�eM�ү�������1;�ϛ�%�|ζ�c6��J&_ҝ�y����|=��5\��ħ�E����~�e'�I��ґ���%�?_Ȧ��?�����')�H�O-m0tH�|߬q��t���Mڌ�����"�V�s�PS�a�X]e���5fIiL�!���I�cW Z�i��▆%1Re}���� f��A����A�1�Ǽ1L���R �b�����d� ;FtĊ���#�E0����!F;c��Y�0FZ�~�I����M���љ�L�A0���G��?"a�M�18q$�<<#{�]����~�0y,���y9����:�}��؏@�g���f
g�$̠=��cr:�5Es@D�,4���f���Z�X�]��U��#�C\��6�h��'�2��2 u�;!���ÇM #jjYt��C�˱4f���gS���%��LLK��Jy{5'q��i���f1u�t�\��VyGl
���W���p*@3����U�79.�@�f�0ˌ�&�<��2T=>�p�����<E�SWwމ���!��Y�߿ǽ�__�������@&Chl���m/��� ��9����}�0[�-�@�d����12�%ӧ�Gc퀶����i�3m$&E��(<��-���q��.`�\�6T�&������L�{\m�l9����B�zԺ����S.�>�~�Μ�|��R )��i1�J�!�W�b��
$���Gu}*rƣ��oJ�n��W�`$�����Q�*���b��Kyl��ta����4�Q�A�����o����D���R3TvE�t���'�鋾����jr,Wq|�7�o�C"�0A�}݈%�!�02r	JE�]�t�7N`Fz�3��J�9$��^���˽�q�@��.*��D��q�S�5�>�tC:��i+���
ҍd/���`&2��Z����>�q�����d���\�O�$�!ŵ�PE�w69�՘�*��3d<���0�Ý��%�����US�`VL~ǖ���>�%��\6����d:����?�Χ���}��3�Y$�ӯ#d��sZ��Y��6���t�,���	�2
-n�ڕ}��x26�إƄɌK�24lg���R�]��UJg�ͣ�N�9Jb!Xɛvj폵6~j� ��#��ش��N/Z �+����u\$����z�g�Ȁ�b������R|�C��RZ�lz?��m���h��Kf�����4�*I�M)��۬���o���x�J3鴺�Ͳ��y�����z����'$���Ը4uw�����G��⪣�S`�Qˬ3�h�2�rg~�-��/���}e���p�]����j�Z�txv��;�}��n�V�tk�R�ڮu:;�8�wkm��S�պ���rʲ����%��\��<6`��xO�~Ǡ*�ãN�^ݑn#���v�޾�^������Ĵ.��;S5�H��I�1u�	�R�t�穛s^3�Қx�$�{r��ɮ�B�`����0�@V��	p��y
A�����KXݏ�+�v�}���;[��Be�ToT�����Z�d/\���Y�Qm5��khW�D"����%��kH�#n��lՀ��5�y��'v���$u�j�r M���n��ح�5j�O����nǓ���I�4$C�TP�f�ੀ�*u�o
"�K�lj�=h�閺5�Z�ʥNm�@eX-�Q��<��W�rL�G ���bn{+����{5���Ĕ!p����܁��E�S�9�/i|�>����m��sU1�d?� #��~�&���n��
����U6f�j��Q���IA5����\ֻ[y n�Es���9����Z>;iBW�dM�*Gu�p�(1b�k;C��(�Y���Cs�=W�ոs�R�֒�_2��Ν�f�����C�
$h	Z脊I��_p�aW(��lw�/U�OՈ�H�ɷ4�8�p�'���3v�2ڝ���wB��a0�U��2��{�������\��|�_�~������e��'SHy��\*'�?r��?EY������g��Y������g��y^���w���n�� Z�{����e���è��c�������X�������R)�l��3�����)����iF�G�!��׮0$� }Ͳ�,˴ޑ������o;�ع�&U�0�Ĕ���\�EP�w�������xϢ=줸��ѭ��@mӚ�#h'F7�E%���-��a�?�4Oڕ�ɿ��d3J~���'*|B�����-9�*�f�Ȏ�U�[� z����ʈܹ:"��$�G����ȼ�j\����+�wV��;�:��O;dOBOb���n�4��&������ľn"�/�[ө��>R�aA�Eg�X]��,��c�@��,��\.?��t�?�Oe�������I��d�kN=	}J�4���?��@�y�F���_�]�K#<������`���2���?��&��'�Y��OR��P�}I?�a�y�I�G~a��$Ѩ���)��"!Ć<��/�d���^�װ�ރ���42-�r��O�O'p����T2��Xk�S�����i��<7�o����p�Qu���k��7 �a0��L����>�v�� �S��H�E-������[[�v2D?�d���$��D~�E��Y6R�|�����&~�e�vت7v�"b���������7���W��wD�f�*/�����p�a�Y?j5�ݹ�M�OB2%�o��M6��h}0hLo �.wvH�Gq�0�"d�sZ��ݽ���:����!S.Ē!XI���G`
�vލ � ��~���r8�!�ҬM��(ׄ��z` ��X��/B'$�'���7����&�r-�P�,���B���ad��j����o_x�A\�^������.����Mf���#�������U]Cjl��9.�y0e>�f���Cz�4T���k �Tͣ��`Y�7d*�Oj�]�;I8�1�ڞ���mӈ|�m���"��-�N<t��=�-����wu-=J���+�D�X��{���W�KBP(��M�pGZd��f-8�^KH�yD�|	h��+9�s�>�.���� fܸ�z&�מ�8%����=���q���ӧ�6b����L2	*�
��H�zvP�����1_�-?���T*Ki/�
�^?��2ɭ��6�+�ޖ��MgX&��o�4��1���V�n�RJ�i6�+�����$X��`�_F�Jt��p��AI��&�b���(&wi$�Ve����\�<}���G��P_WJ�j��:��pќǾf�!P{aE.�!4�jKb�ŒOb�<��q� ��~	0!>���-"CI��?�ݘ!y:���멄x+aȂ�8�3%ݟyT����xX�`���-S�	�����r�P�������F�#8���ܶ228�қ�X˯]�?R���%L��v���?�ln>�K2���y���!�04�%�t�� �,�)�����ZV������e����t2�̯��)ʪ�Ϗ����.�>f���ta����s��ˇ8 �	��
N�e~|q���`�1��8�	bʆ�9,$��)Q���fp�����6��f�;� �i��7��f�.O����tK��Y�~T����{�ZؓHD�X�7�/�{�u�Ʒ��D,��//�!�Sn�1Q=���73�l��wds�$�
Q��x~D��	��[P���+�^�Q3wlף+�э��.C0�X�W��(%�I�Y������)YH���Ln}��I���ҁ��9�0��2<}��P5������D�/�cl�,6�.���Jm���i0��Js�t����_U����xlU�&���Y���_�=��b�R�_Q��[��*]H���<?��f�k���q��bB�W\x��Hϣ�#U��g|i	e���m������+@�P�Bx仚9(j�1�`rx���E��O�Աۇ��]7�ߗ�����С���E�w��*���P��AT�-�t�ZCE�m�CsGsM��~�� ����*��]�-.@���_�Zi��#yoHx���D��;� �����n0�H((����Lu�q�t0���994�{��F
H��g�Bf�b������J�o���?6j؎�G������NH�!��tu�og�DbG	O�ү��^=��t O�r>�V�7�&�`2a
ֈ�_��+"�'�.b� Is�4ޣ$opx2�I��<��%��1O���	��F���UT]�S�P����t�����"@��=��r�r�$"�������NB�����w��7!ǵ0|��"�Z�3���z�	_	�ּ�ES�H�&@<��k��lR�9��_~x"Ņ�%�_!"ae�#����+�д�<xNþ
�
���y�iy ��~� �2?���[�m��|��|��R������27-Ϟ�Sk2���g2�	�We	��x���Q8ؕ�&2�y;sVZ�ȯ�=ފS�t����g ��52�4OD�/-�H*%��}l�T43-,L0�i�O2XL�mg��6�R����˅B>&]�I�4�������R/����Jv��<1|L$�ڦnF�S"zA�T�O�.DXE�]RU��v���m~R�2u���"�J�KG��+x�xr�s��M/k3.����-�á�@�vzG����2������#@�_B�иdp�]�@8�ЊB�ȑh̙;�W��-� ���5�0�6�=Wn�JB�'���z@g�v�<u�ȂV�����z�̉ȷT��뙥Q���P�!��8��,;��"G� v-n}ab�9����Ǐ���D�8�p
5�����y&j`T� ��ڢٌ�`gɥ��@R� ��l��< �<z����-�q,-O���֞��i�sۂ]���&3��%4����I�ĉs���qǉ���$�A�Bڅ�.hA��oH���<�>�!���Z��G�s�tUuUuUw����RW�����|���s���:j��|aF[�u�h�u )���{����&vw��6Y��M#(�ƀ�O�z���9V�h}�]/��<&X�f}�P�L�&z+�7YL��}�8_i[y�W�x�Q�����زc�1��܍9��|�<��Y5���^��w5�s��3sp����o8��� �!H$�}���8����o�o�_?�}x��~�����S�o�Gj��a(mh��`�ڨ50-JQD�F�J�:���Q5*�i*F����(�֢8��m�����!�
xi�B : /z�����8�ހ^��џÿ�}�֣yx����q�����w2�ނ^9���soy��[�K%׹q_~�M�[�˛��:9]�?RgU������ծ��_������A���,���	��N �D�?�3�~�_���_��͟�A�ߟ��?>���>�W�{��A�����{�\��т+^�f]�����?ĈH4R�UX�"u� u�#Y�GJ'p��܁c��:�#(�7�(��#�/.U@��[���?�|��şD?��?�ө�������A��o��o��?�^�������o�����z���+"�����>����B�~��>�����V�&���Y�и ��bYZ����\��iF����JR	�
��)�0��v+��e�n1s/m,�N�����`+olUd���MQ>/_lM�5��s�*���+�ź�ҜF�Ve*�d\lUU�l�,�7e@L�SvN'��u+
m1':�����q�ҴW�P�Z�j�������(�-`F�N6k����D̵�����⧌{��4�)b����q�Fb�q�Ƣ��Ԫ���+���T��,-o�s��q�A�-�Qa�h�=	�Tr�t��~3��*>r�~�7L!��
\�Z���e�r)��k�9�ŤI�;=�+nE��J1��7���:=� ҕ8`b���9��ʲr���	���"E���!qud��!o$�?V���jw�]���B�;KW�v���c��/s9��9Z0�٠�
�SQyC�)��y�L�A��a찮q�y*=6X!^��N��R�0��q;JOz5B�LG�AJ��
�-��R�����)��&�=I*-�3vQ
��a&>�I�˷-�LRim�KRi�V�I�yTj��$����MJ{� .L(�8%���%�>��3UpiB��8��22oO�X�'�T6+�R\�rJ�I��v�HZ�B����TL��M�*Y�9\Tʓ�P�gsD�gq�I��I�4^��ߑ��M�rD3�AU���P`�K��T����uMP3����D�xS���T�-�V�Yl��	��F��Tt,��)�D��v5Dr���R�)R�6#���nGJ���X�塚��9΃rQLdU؜�EN�R!G_��y��O�(t��'��xiG�s��	m�?)+H�bZs���*l�X{v�젾��GR����9�l�ML�
�D�ڦx��z�'�$� ����*\K\�����)7�,1��\�L�#SM����d����̚Ą.UJ��z��Q����>�͒@`���Us�U����v{NWm�2q��k��$懬v�F��)VU�ɼ�A��Ȩtk� Y'Ҕ��c�O�NL0*��1��`��;�!S���])�9�#�d�۬@��$=�,)�Fu>�IM�P-dZ���6ڍۙD�A/�8l�����]��M� ����}���K���R����{��ƫ���?��:,VZ�~k��z�3藡�]��`}�o�W�«����H��p������Z^�n����Kv���M�jE�wބ��5�����k����?�}�>�{�7۽�?����s�����F�IF�L�)�$�̕�zC;c�U�i��G��6�EO�{͉-��������Q͢k<�������,�KvxcE]��4�E��f��G��
x���
ch+c!0'�CdGbiZ���|Bf�H,A�	�H��^V��d@Y�4Iթ"e:�P�$Bf�V�TS#h�Sӵa/U�F�y�K��K�H�e��,Y&�����V֌d���0F��~�9:�����4�ŻP��dXF�����aä�x�-�Hr�ƻ}���3��w�%Z���t
<b()AsO��Y�g�l9^C�f��)"���I�]θ
�ZXv�G�1�Z���C�k �&c�M��CՉ�.	�$��ʇ3�l�/�G�yi�a=�\�e��B�#��t���3Cc�������S�����?}Z ��tq-����\�G��UV�>"r����gמIV�-�eܦ�)���������uw�ߢ+��s�_�]+Yc9~5�]�y22o�GC�ˎ&�je�Y�*c�X�d���R:j�L���K�X�� �K룪��T)�u�������ɶ��D�J_�D~x�	�i�v�B�_
eV�i'��,-���K��TĻ���#��N�1��f?��t�f �)��Ɠ�S�w���&-��V�f�x��'��R���d��$iNG�WE>1������E�x��&L�'�fϜ���H;	#0��2ލ&��O�����>!)�!��Q�t�]6ɱ�PL��T#�U�Ը����W�d[�G\wF�;c�;�6&�D_hLT�[��'��l����|Ҏȅ��b{�!a�<��)�����=�ҍ�T�`��<��բ�|E
��(�H�U(t��xĚG�D�́gQ�kP�ڢ�cP�B���#!F��sGՑ��vd#9	'd<��ѩ�@[�Ąr�y7�A�i3eK�rm:F�z�DW�\��Yz����:�͇\�1a�q��
<V;5Gd��H��U>�a�L�V���pV���3mti�D��
�5Wn��W�����f't���O�D2_y���Ep�Es�p40�Y���u��_w��\�����t��-��T9_�,9�^�^: �>|�����M�����׼@�@/���������E��j����Mf��8�t���9}�K�æi�et�5;��+�����+���ԑ��!�Hq>,����xuS] �V��Y���!x�qː���T��n�'�����}v�����#��3���������t�s\��]��#�p���N��*�ѦE�����u�l��hе����^̸w��Fô̅�t+�[u��ny�e��~�N���ё�εH�o�F3��M�07G��ȋ�g6�U ��\�E�7��r�pC?�ؾ�,Ա}�i�c���P��M'��'yÙ(�.n8ul�t.�ؾ�dԱ}�٨c���c���±}����~/�a�kiӾx�����[�'���#Z F�_x�~F����?�v/Lf{���Q\��ߔ���k~�z�v�����E	�Q�q	 	��.����&-�R|eQx\eY�J:>�T%��%c"z���N�.�fb՘��um�����X�jv�t��CR�t{>�G��:Hzh:S�J�lCT�6>����Hי+���}~pS�o���s\���NO���q���� X�,���~���~��#�o������=�~����� ��N���-��l;�B<�J�"	��aG�ġ,0,8�4��a�l׈�����p)�R�dY+���<��mt�t�$Kӹ���)��yLe�м�uX����]�ۅ���gx���B1��M�m��B�;V2����
�Y�K(������m��̍����������t����"(���z��1����� 7l�sCy�>��&#h�����h��xb�9���'�?�x�_�����#��?����2e��w�q�E�?9�c�	���'���������)sN�� �#�������`��/���^:5��=@������(|����~�z���!?���������`�_S�c������$@���������ǂ��;A�/���{��}~�ا����9�?������� ������[���c���w����3ۃA�a/�9��A��� �@D �#���}�^�?>��p��.��Y�`	�����[���c�Y�	���_���=���'ϙ���� ȶd[
�-]'ے�=��`/�_���?���������[�����o�� �����������������0�?���k��;���?�������#ș��8���	���5E�E�:�z�CH�^kP��i�ވDq]'�:�a��h�(�݂c:L�d��	�[�g��~��!���������_�8�A�;:1�#0W�)lb��^
%)�CM&�+�	��U�E�	Eg�J!���~!:Wu���bH�^Ob�$L��$���X��F���īv�l��=ڈ�����(T�zI��_�w�4����?��_�d����}������������O�_��=���)<����?��4�?F5D4>��h)\f`����Ci���H�aU2,9�Zc��_�)���ԥ���ԴA7�c�RV:8�8�ŉ��&�1)%"Z��j�I����(ޮ�[ɒ���v|`���P��rl��]�a�#���O���k�{����P��뿂�|C��W��W��W��W0��?���#�B���Y�	��.pi����˜迌d����誹F�h�y&O�;��<u�wr�c�q�Wk3�t S==��G�hX���+�?{Wҥ��mߘ_��u�oo@'���b7y+@�^���Mݬ��Ve�� ���Q�i6��c�}���ڽI~>����i;،*����ae��N��xJ]*�T�J��9Zw�4�;g��)�<t0�y�w��m���:{���ne����I��|��6%{-1k�Oe
�X�<�~������Evq}{����a���5�[�G��|�U��Թ�2����w��xVXs���"���g�i�6�j�:i��X�M��k�e�^��.ɛ����X��(�ТQ�~Bj���5�[|4��r~�?��$8���?#<��@�,���M��?�����w�I�����.���GN����G���a�c��_����0��s���ϭ�H������_L���0�0����W��_,��/�!��_����>j��9�����$�?����a�a ������?�,��0��?|^�������^�_� ΟP�����<}�����A�K��@�����o��aM(����e�?K?����q�T��m�}>9����K�8�+��?T��
���������	�?L ���,�������i�b������?�������Ä��_6O�6�<����������,���� "��]�Ǖ�y��8�=�o���7�?��Y��j���A�M������-����(��=�{��U��_�T���z��K�|�v5�x��M���l(��Ҷјt�vϱ��e׋@�zQV������������*�NuN,�;�.�n��^B݊@�Mu+���n�ݫC6W��b��������Yd��5�I����j�rܸGZ	<�քLY�V�o���ٝEX��X	��E0�|;�n������J���T����������������?����3��� �?B�G�������+E�As�R��s�?"��i ���9$~�����4@�G���?/���KB��o��|��������[������#����?��R�8)�E"EFє�6�@�F`c��e%�0��DǱF�$F�,�SQ���޿2H�N���P��o��k��������[u51UGs,���z�\?�t���¬k]��ހ�%}i"���FZ�I*]��E_����Š��F�n�/k�8W*��z;��+�툭6�I%L�����^��C�\�(k)��,M8���q�/�,.~���O�y���I12�x���F�ܡ^>���ݽ��/8a a�������?_��o� a��W����QJ��������})>%H����W��txXg�ZбZuJSFuɣ�Bs7=���\�WS��������=�,����M�����Æ_U��i5����9F47��:ۯN���r�Z���m+���t���6K��b�ţӆg���(�X�����?�����p�'^��D俠��4@��A�����2�@��� p��J�������o�ך��8�;q��Ћa����]����/= ������k!��:��2�he��!��ϥ�҈���W��Y-(.s�O
��r�b"K�Y{�}��ڍ�����a�5�:#O*����|-��ӐZԽ��=�V�Y�5���jq��,��kZ�����D��^��j�7SY�6�4d�փ�n�[.�F�(XC�����]M��[�}�,'��*�_�]����z��fp��2��K��6ꑛZ�.��f�Y��Wϫdrv�~�-�}l�(^��2��5���h6lc4�ě�c��pc����G�������_N`$8���?#���4��b����E0p���������DQ��0����/���_@�}��/ 1��H�e��b�eo'��x�H��(1HF2}�Jx�S�X�2��FV8(��@���������#�?����Z]\�95�O�>uR�q�jVN|7��F�M�;�zX������l���ge��~$��̣�꿰�����;y������U��?����pW�+�,�?��)�u�`8H�|�'GJ̅�>̋��<K�b��)1�@����A2S����Q���X�+��!&�Z���3VM���~<:;�8D�S v;����������۴2�3q�[Z�ߏ����f���$�Y�a����������a������/�����_�����[��;޿��4��0�����>a�*����ϱ7����A��c�;�����������C�~����q���ot��$�?K�����p���l��P*���������/0�J�����/���?�����J�����e_�O	�����_�������?D}�u��}4p��?�d���x��_8�����u5Z��<��g��W�UC�GB����&���.������̢1�/f߹��[�Iל���24�õ�����Ѽ���q}�v��ə����bN-|���\c��oCT��m_CT�[��z��ρQN����gr`��f0�9�eQ+^r`'�����]�7�")���e{��o�E>�I-=�ǚ!/�Yž4gm=m�f�V53'B^�w�4k2�ܝپ���U���v�v�e@�.��{�1��Y]_�>Q�!7vjta$Oٯ�-ڥ��T��vT�)�ո^G[�V�}�����O��� �ϡ2޴/�P��I�����<��ڭ�IC(f[^<z�h{n�7�x���oS�F��#����������6Ff���I�W¥2o�⾒���MCc|i��n[�U�":{~�U����@�O�rߴӨoR^�ȃ�W��aD�G����<��@I ������������������ ������_��_X�=�o���f��{hon�<�j�y;��[s�����˯�������˴����u�Ԁ�OuCE��q�&�Ψ�����,t�~X��u�6���������1��1j�Ђ�^��neP�{o�2bG���)�bx5�9
��
mB�S��J۪f��I�ky�����u���|�.�\4f԰�oh�Mk9H���QSm�д7��4�&ia�nO�3g���<[I�\��Z�Qy�z*�z��p����P��=^Յ�:����م�t��jk��$��j�m-��z��{Qh�v{O�5љ���#tp�헗�TTF'�c����|��DJ7�]�G��.�0T��ͤ"��6C�(G}ZM�'4���m�����L�i�"z�h��;���u^��S��~m׏���<���_, @�=5��r ��s�?"�_x������,�� �@����������{��������<��LW�Ft�	������?[�������oMT�[��d ��f0��Og �o��x@~�H=������yw�z�f�#6tג�ʄq�|.M�}?\�Wǚ�U�uv9�l�:��:�Q�|h�|�G��[��Jg�g�mZlQ,x��s �k�=9 i�U㊮*<�(�7��e�f�_o#uq)�P��b�ͼ�]��/9��Z?�J��fM#f��P�3�7��f<L��Y���K�VG-I=+��d#�j7sџ��}ء�tl�x���(�k�O�< B���/�?t���r ��s�?"��i ��! �$�8�/p���p��[[�"�� �ɀ����2:g�v��/��?��#���o�O����cI��0W1Б$1J2G˱�Dq�r��,q� �SD�O���%�����x^�`J��A�?���~��7���VKkn�Ue�Dj�Vt�E�5\������n�۰���o��Q�<������Ԑ.U.~���� J(~���^W8�U$��:k�}6������f#�j���Q���:Ҝ���a�ۏ���������|�������_y ����Gi ����_WX���� ������_��:!��J���ʦ�Ry�Gz}љ^���;kL生��ܠ�׏�y��[��*߮���~fO竃�ţM���ItbN5{W��-�w��l��,u��9F�ͱi5*h�i��fљ����GA�����oI `��_��O���H�A�Wy��/����/���������,D��?��������S���������鍼lq��Ļ������j����n���&��b�`�XR?��K[�~���j�8.������4H�:�SS#��v=���^��X�d(�݌6�n�\��rɕ]�e�{��1�/|��Gn�Xۂ��v���J�z�?�:������V8�������]�:u�:�w��,R��$�D�uhF 3�|߈��:�e�rGm���\�of���ꘞnץS��Ù�Y&�n.O�U�j}j�&q�pP*Vk9i�s��QZhk3�d��+SEe�IZ	����x�
����?�V��������3|��#^I�����?�A����������,����ߕT �����,�A��$��h�Jp��{�r0�`�+����0��T�/��?����?�B*��n�G��,������a�Q ��?��s�����C�����������x!��?��#�������#^�	������`���/0�巶��
$�?�P�σ�Á�_�C��\��?������ �������_,���p�O,p��{��������C�����/U�	w�?0���?FA�(� h^��)�2lć4RB��+�Dˢq(��,#!�e���R� E0���@��4����	����W������b��0^�&}��;���p~���Et~�	����^�Fi�����M%��ϧ�q2��K���� �X�n��7K���,B��g�*@�d˱�K����(nm����[Bk���3ӺeVJcһ+��~�0�)����}�$ia�n·�A�d����5����~��׆6�g�Ş�$S�b�����)��Ծ���C�����#�8Q:D��L�?^�w:���=���B���x��iҡ�?��w�����������Ǎ�3�����;���J^D^�
��fs
����HERSi*����(frdNMɩt6%e��H"�@��)���S���������_�����tu�2�I�|G�z�]�\�TEKz�Tk���j�6���b���˨Ar�YU(��i���t�5�D��nU���>�F�ءܔx?Z�3�jw�GS[t�Q�)2�7�n�E�(�����)��q��x��������O���?���8�:���=��T����C�?�K>����±)����������_DG����G��c�?:�S{����A��?�2�)�������g��D'�����#С��G��S���!(>�!>�!>�!>��������?�N��st-�6ı(��o��$�?��]���<���OޑN�����t+��@�~�����q�goE����e�]�����[�a����j�?��m������ο������V��Ȟ#�^U$�oԵ;�m�u�.A��b�G�Rי�x�������*\E�)�>_șw�aFe�#Ζ��-��L�Q���'v�{��Y?���|�e�j��O9��W,vǍ'6~�[��.b�iW&l����=MTS�\o9��eh,h�&��(ks��H�*d��:��R�[��r���q~p^񉹣T��z��[��`�����?`:	���>���������>~����(��o��$�?�'��� tZ��uh:���O4���������������������#�[?vk�~�����w���G��������?������^�����e~��w؆�4���Jk�&�[��h?��|�^�uv���:?�W�=�	�h����d̑w�CaU�����+�3�+��[�~D�V�{&�zB)����f2�n8g�MO%�\������1!j�	��Dn�{�ߘV�z�B6{z��M�{��1�r�e�l(���2�B�a
���W���Q
nL|��E���\��UW\�*�V�^}`Ֆ�ƍ>��i7S��N�+���p�5:}u$V�jQT����g����/��lũ+�Nf���W��W��L��>|!���}[�
l=p�;u�Us;e�:��~�o��|��ps{,zY���	�S�����bޅrEl6m�/f�:}�.3���Y�Z��x��غ��+m�q���ڝ�A&'����|rb�ϳ�Jv�a�䗼��*Z7]�X���Z������_�g�.q3��["��y&�]*�~����1���G�Y��� t���ײa���b�����N�SOd!8�+��B����*QYYMS�Lf(%�KKL.M��y	���rRV�s��ʤ�LV�S�L�䌜N�S	��?N����������Я<�߹���ӕ�Y�d1������}~�������/O���;M*�����\N�K�3YJ����y��_���%b4����ͪ�^ʦ5��)^r�lAs4A/���ZCK�I-��\��*�R���+�����y<:�����Q�����;�����N ��|�<vc��t
��ǣ_��y�������jY�Kx㎚a�LV�ٜ��S9݅��m�?���4����zVl���u~Ѹ.����P��.��j̐3��hN���
�A�|m�\Y��{����������2ɞ4N���[�4�:���N`��ńl�+��?����x���(�����������Ol�7�ۀǠ�����g�_*������=��������Ƹ%��7���VJЅ����ez������Y�_4;���ɟ�@7�� b۞ݻ ��ri`�Sv��J�M ��`�K�b:�*�<��V�zo�􌜍m�h��\�گԊ��-tJ��L�k�Π��ް�r�M7�E�`�+??F�[۞��9�jc�'�q{�}7Ԣ*�s����x@�_��:���ӄ"��O���a�@��rR�Z�QZ�����]�r�sB��r��f��tL���y-<��ݞԹs�hr������j�'��0��2[�|ETɪ�-�ɜ�]����hT-s�>R��IX��n�,�i����擰k5{k>�awn���н�s���Tr�����w*{��9�O�Ź�j��&�л�O�2��!����ֵ�*\]ً`t�=t` J��@| �V�梦��t�EE����:�/��	��$J�^�:B�Κ����p��(@U7ulp Kֶ�)j�����;�����"m�� ��2���ށ�h�sx�� k.��%زۂ��:o�񬻀rЋ]A+4  A��j� C�]P�����J�2���l9�4N$;�^�7�}�c�]DxS���_�zW��?J�S�������MT�9V�Nt8Pĵ 4Eɀ�6Dz�0tYw��l��ɯt�-ώ���gr� ��� a�|��/�,|� j>х_Cm9D|�jT"��m�k�!�����:to����8oG�EBI]�h�0�H�><�8 >w����P�z�@��EP)��+pD���J��-><j3�e�s3����P�knT=$,�-h!�������.�w����.z��5�}���N�}����#����o	tJ�og�e�Ot�Ɩ䢴(ԶK��PUۚ��u~`�zKy�R�(ϯ�����Ļ���>�}ղ�=}v��g�γp��VU�{���8uz;5J��\�!�It�Pۅ�-�J��H�h�p����e���/ȴ�|'hU�
��ܲa%�DDM�.e�R)���<l􉆱��'>�@⹖�5C�gx8�w�,|����[��^P�Y�֏z�Kizs	����H>/}�<����J�T�
|���/�������G�bhrmOvC�XU>o��KbG��l��!n�r��s=� Td�s�!���#h`$˝D�"HwN8w��Pü���,=6:�+��iODm(�|}��_Px�2��l�Irz;�n�Tt��7�%H?�xT�n-����7������7�"��S�>��O��6��H([�(���n�h,*J�a�X��#nީDAu�t�+N����w-��%�����'�y��3&��Ba8G�&@�C��EܹJ�	��p�lY�S�o�b����W[��sW���¶T٫|$9��YB� �\X���\ΰ�H<�ׅ>OH���9��4��a�p�쭶���M$�`�R ��ѝ��@?��
�ܢ�ub����l���ƫ��,��ө,��!�8�.�'�A`�e�!{b�}.jhP���6��!��DF/?����92�����m���c�e�m�Y��Е�{�E2��Ů����"{
K|��[8_��ސ�f���S龟QU�X>"M+��Jg$Z�t6OC1�����ɨ�UJɪ�(�R
���I��|Fd��x�̈��0No�βd���B���z	�	E��iyB��bW5��7��{���<gp�c,��(eҢ$I$�#���P4ddR̋���0y�%s�L����S�%sy�d!%fD�\H 8n�2������)h��exs��\������[ku���xh߆v�>)F	�`�sM|�����hl���Զ�)$�%�!t��m�Y�	�v�@��^NV���[(t�n��L����ۭt�B��,\a	y-�~��X/Y/W�gk�n�R��,t�j�B���p����o�3��*�}	���Mj�Bt'Iǖ�r�<)���}����V����#'����;��b�i��d�`=�yl)���G	��9��<ק-�r߿Ph���O�����&�|�#`!/U����A��e�����ǔ�N�_�M:��
�B�Yi��<S_]&�IgI.E;i{fd[%�m��ę�"��N�w�n���D�A=+[��Wѫ�f��7�J�!��N��jw�Q��m�}7��Ѩm�yL�����D�?(�c'�z��c{B����X��
W�͕'�;��f�/��N�զ�d��"]��9�*�ü��8��\D��\ݼREÁ/�0��I�"��^R�!�ܕ�?��������>���7���+�����T�[d�>4�K#%~���t���t߇�����Ǳ�=
�8*p��NeẨ9�h���K�9��[\�sc����P��7��Ä3��<^��IQ^�GS�4�������; }�����IIt&xن��Sb&Pu�q�m��
�n�@4��9	ϝ\�%z� ](�Yy��_�	,�W��������s�� �-{���7��Ԗ�N�z:���
���'��g�@_��6�^�;�?����3𗿀���_�mw�!VH0ޅ` }���yg����p�������v�`����9��
��=���Qaޔ�׆skNj*�Gl��6��d�<�=[ݾ����6ѰHA#��m���5N�[��������!z��ѵ=����;F�����/�����M���| P4��?5���Z��czm��	��d�J�h��t�I��:�?�@Leσu��C!�5@6������%�XqN��&W�`�G������O1��Gf�����x��A�u��T��*��剅X�(�B2�j8 ��udx5
��,�ߖd�b]T��w�%�8'M�0�s37�y���b������E1>���|�H�'����r�-����5����l1�4Tz�k���+�}��l�VZ+���fh�-^��%6����	<�r=�Md�!���׸<w�������׾�:��$,g�k_&��2�M�r\1ˠ\x�T������Gi �ﯘ�>��]K{P�i|P�O>��b|X���Qh
��wf�-mi9���� ��vv۝�vf�|"�n��3X�����.�Q����77���{xW�$%JZL����r!��KIψ|	Қy�\���`Z�_�iق�ds	�v����)�𧄝m����J;!꿹������V-�x�s}ـGUؖ�l��
�Vkܲ�����"���#�,�7�篭���v1}�*���λ�\9׳�,7k<���	�gB��̡�իCw�M�?;��9"�F��G_�Џ'��Lt4��0�&���X�:�|��x���`��PE���2_��{�W��iZ%�B�:N��1o�;}cvZ.�,��[(MK��47F����;J������n�C�A�cY�u���}��\]���%���l��"���И�=p����}ԭ���j{B�v�,ܥ�X��{rf��_�y���]��Nd�w�߷��0�zh�l�RA�������+<'�u���y3����O��H����yd?�eh艾��grF"�Eu�vv�*tڲ�x�N!R$�ʪJr���Z��;�5�uڬuP��;���-�$�<F$�|KUN��'B�F'��I��xƢ��t��:sZU�<���|���G�n��`0��`0��`0��`0�<~_)� 0 