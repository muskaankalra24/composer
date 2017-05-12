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
docker pull hyperledger/fabric-ccenv:x86_64-1.0.0-alpha

# Kill and remove any running Docker containers.
docker-compose -p composer kill
docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
docker ps -aq | xargs docker rm -f

# Start all Docker containers.
docker-compose -p composer up -d

# Wait for the Docker containers to start and initialize.
sleep 10

# Create the channel on peer0.
docker exec peer0 peer channel create -o orderer0:7050 -c mychannel -f /etc/hyperledger/configtx/mychannel.tx

# Join peer0 to the channel.
docker exec peer0 peer channel join -b mychannel.block

# Fetch the channel block on peer1.
docker exec peer1 peer channel fetch -o orderer0:7050 -c mychannel

# Join peer1 to the channel.
docker exec peer1 peer channel join -b mychannel.block

# Open the playground in a web browser.
if [ "$(uname)" = "Darwin" ]
then
  open http://localhost:8080
fi

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� .�Y �]Ys�:�g�
j^��xߺ��F���6�`��R�ٌ���c Ig�tB:��[�/�$!�:���Q����u|���`�_>H�&�W�&���;|Aq!q%H����|���Ӝ��dk;�վ�S{;�^.�Z�?�#�'��v��^N�z/��˟�	��xM��)����!FW�/o����;����GI���_.����^q��:.�?�V������>[ǩ��@�\�$M����5|��/��t9��{Lĝ��^u�=��4������<��8^���k��P|������E0��pʦ\�Fi�Fi�uH��=�E(�GH�G}�"̵�"]E|¿�>k�U�9ʐ�i�Sċ�'���/>�}�!et������Ć��D^�ZO�M`���h�� ���@EYF�]6�/L�&����(ŵ`��l�ZЦ
3!���S>�A���U��,r�4A�8�:VblRzw��xn��E���uVz:��)K����ԍp7��A*�D������8�uY����G�D�ˁ/ԵoߠScEUx�1���M�K�������������?
����R�Q�˸:��N���=^��(�cO�?�T��<�����$�ڼ����7�n7�́P֔��'���e�ϚKq�"Zhsa���gݞ�	`ƅ����Y��i1o���h(ō :yNik�����֍��2ġ�i�<n��L���xYCrf�ԙsu0�O�m�w���q'�ǅ������b<j����)1�C�Aɕ��`!��C.��z�O�-A�(`~n�D�MSى�C�C�����������N���9�5�țr7�6�8Xs�*���f�b.�~�|������[K���
�4���6A(�(:�)( 2�T_#Bi���Ю/滑D���H���`��Ɗ�Q+S��_vЦ�6��0�Y�%C��#�w��f��9�[ݙ��\����� �������k�Q���N}��=/�����V�x.,)@�@�����u���(��EƤ����7+&@fK��(�t isy�1����R��(y��@����u��@.|[$�%���1�e�����}v�7��k�r�-'iKj����Ũ��,��Ez ǢϙE/�f�\�}X|`6<���,����i����x�������(���*��O�C	���2���������u�����Nݯv�zK qO��|h��x,fȑ8N�
��Q/!T�G��vB>$��N=��"��U�TA������^���i�$��h�o``a���x6ad1Ok�K��w��Dѭ\������5$B}ٚ8������ˇ��B�7�<6]�+�<s�y�i��}߁��{o��]~�-C��e[�*�ቪ{@k�(̶p-�#��4M93rր�6�����C�� �v~�d��Z.� ����>kr���r�Mwp�x/��-��))�D"�a�t�zr�a�:D��K}0�m�`B2���q���D���ϛX��X��P���o�m������}?��Z2��h�Y�!���:��x��_�������H���("��9�_���#T1\*�/��_�����������x9�!U��%�f�Oe���*�������O��$�^@�lqu�"���a��a���]sY��(?pQ2@1g=ҫ��.�!�W�����E������vO��M
Zy8�XOP�Yǳ�>Wx�qpa��Q��Ë�?k�؂m�
f�dܐ����[&_z˖2�'�!rXm|�1�>��:ݎ,h��ܘ��%���_�[P�	v��lO�*��������?d�_
>J���V��T���_��W���K�b�O���|���H�O�������L���7s(<:��P�қ�]���O������.:6K}o������`p�{�i2����U�>2�2<�$�zo*ͭ��3A>���w���]����t�x�͆�f2o�z�D���D!P����]�p�r'�v�ó@�D�s�m�ȸ��IG�^p ?G��qڠy��)�8�9@z��%�i�V��ڹN�M�|��6Y��.,����μ����´gOM��@�$0A����^��Y��h1	�x�� ��i��=SZ������SMG��v"FR>�9K����Ё��yW 'Y1�������)~I�f�V���F�O������+�����\{���ߵ�}����"h������B�/�b�����T�_���.���(��@�"�����%��16���ӏ:��O8C������빁[�8�(���H��>��,IRv�����_���]�e���?�	�"�Z�T��csbkL�6��s�U�����Г��b�J }'��N�VRjhH�(�Nb{��W#�D�Q�[��nno��P�' �!H�g�A+z�d�~8�����fU�߻�x�ǩ�~���?J��9x���'���w��P�����B�߾�L)\.����_
�+���/_V�˟�q���H����b��(JW�K��������I���O�����]��,F,�8�M��M��b��b������,����,��h�PTʐ���?8r<��Z��|\���Et�RKD�D�ń���6�F��w9W���i�~�~q�g5�	^�뺻�V��KQ=�#r�1v��2��-ptˇ`�Oe��4v��U뙈k���6H0{0��j��������v�w�U���w��P�xj�Q^�e������K��*��2����������(�����_����΁X�qе
�%,�!?;�y<���%�������a�Ui��U��n�/���CwA�����h�� ���=hZ�a��-
'���N����B�N{Ġ�o�վml�8O`���L�z��"<c8x&'8�d�ub�ysD�������⢹���l�LT0�:����=�m�(����1��&1`[���&�0�BK<��9ޭ�+�F��5a��7�STY�M9�S�Kw*�vg<6� n-�y��<�K�In{.���}�?�� �'�)gSs��wu��{
mE6��l�q�s�2�)a�l�i��@�=��a�Sb3�=)�h���g�O�֪�Ys�P��ϋ�H���v�w��8^���෰�)����&|���An���(C������(Y��^
޶����c��_��n�$��T�wx��#�����2?yf(?��G�t���@�O��@�q[z-PS �]��'n��c��<�������nJJ�Xڢ��#[����m�5����Ԕh�;ķf*Ǯ�	C:�͘$s�Z��������%��/�I_M��==���A��}�R{���Ț���	�H�6k��y�^wӾ�R󬑬�R��S2���k�g�`�r����߃�N�Ѱ	#$�{Da�6������H���q���MV��෰��g�������Z�����g���������������j��Z����)0���U��\.��������QU�����+��������b������T��V
.��#l��0�D)ơH�p�g0�D|g4�iGp%2`}*�}�\sëS`~+�!�W���B���O)�`�PZ�d��a�2�f�����9��6ض��"o䑶hQ����hN�m�`]	otw�K��#`����;VaDI�1�ַ����0�k�d=�(G��b(���:�b��W��/v�~Z��(�3�z->�?��h1۟��B�h��_�`�Y���������O�S�ϾB��k#�K�6����Z��?]�^XL��vҩ{��_wuCW�5r�\ًdb�>�/��4^F�r}��V��I��e��7ͮ"~�����֫c;����$N���:�E#$����_��b�F���Z�&�+����:jG�kWE��q�"�.�ګw~r����sEsY=pr^�ʩ�6X|=�M�jWީ��b�����T��o}���^����Oo�vT�
׾��*
��
�#�i��W��m���VWD]�o�*�sӑ���A��~�r}�y���ڗ��h4�·�l_+*ɝ��sG�w�:��4̮o��Yz���vy�Q�=Y��=�x�jiA֟� ʒ;���
�N����#�j/���X�I"}~����<<��>ΐ������yew�����ݮ�������*�~�����=�����E�����wjj���2����'k8�{=��ԅ��z�q������Hj�Z�a�MX�@��)��x>���b�?��|8"�۞�������n8��H1�]]��@V�� ވ#��!+bw`|c��㲪82��Ӎ�8�T�9#���j|�,���0O�lo�N7K���]]���u�7������H��kE���N�E�Pn똢DICQ�/�ƆCQ�$J��78)`p��AR~k�I��)�>�A�Т�K��$�� vA'6$}H{IIi$�h����.�C������~�މ'��1o�V�L�-4���[��Mgs���&�+��PB��!�P���):ː��jx0ہ��K�r�̭t6�����ֵc��'	5[_��h6E&��;6�z`Z��Xtk5 �z��tL�%�Y�mA�	%b´�?pue�UWE@ppb�k�5]�%���&��R;V&�]
4 X��#vM�q�%b�-#w��uj���T%M��:��43�]��H�b�}�ӹ�D��-�K�,�B���i	���X�{J���"Ι7��}0���37�UY=4��H�-����g�u�h[�S�F����[(��KSƪ�&jb�f܂�}s�5ESl=�bl4]�!�[4]h�p��N�fr�ԁӳ�i`	N��p�}Gp:;1�Ӏ՝�#Z����� vv����#IW{�ڪ�~���������)�Nk��{Nj��/ltSi6�6aq��O���;�9���rû숂��]5_��SPFV&:�t^3��?���Q��hzC3�0�]梭,�>���u���>�|�T�Wr��c��öh?�I�.܄"7��V5JS�Q�ot��p�gI���-qAhIf�r�~�ȵ�}����+f�%] ��a��ν"ϧ��{v�!��ᓴ
m�f?���u$"��t\�x��!�v�1A+��$f�ioZz��-d�s�~���T��Q�C�^�_�_��:}����[߮�����pnAk�����٧<4�7�"��W������llx�;|��8���7��Y���[��9���^K��@i��Υ������.�=�J�xf�{����`
�!����z0�{�}?/�!�����8*�����pf�\4�w��#�7���|�z���n���~�֋?��^f�a�;_f�s����p���/�0.�����?]2_����5�������H�a���>;��~ /�JKF�9��ln����A\Rl^��Āͷ)s�uNZ<�$K��D!�� #�w~[���!r}ذ��	�z;�*P����z��W�vKh��h�W�b��~v�	�.�.a�AUZD +�u���Q�.��E��5����>g��%X�b��(���9��-\��T�o��`B��u4> dCf�<���p6̓3�U������e)���GC-��͔%�R*U_��/)٪e���L�#%��o��p�@���W�u���bD�����д�߬D2�����}��/9LX�	�0a7a�"_?a�#&�2�"ltnSO�������蚟�R3B�`啕���#J	|#�mh����_'=�t(�V��Th�*4�*:4��?���\/i\�;���hO�i9��-o��Rh�q�鐕��=.�e���a��tc9�������G�d��
�����vQz�C{e2��:m��F1��F�����L �扆�'Qh9N�
�^k(��}��m��Mv?�,QjI��8�ی�;v�w_Y��,k6`]P�=on���]�$�Ψ`<
zS-�rű��
/9���=j��c�a-R��LGn3�R��=|��1��6���>s:e!9�-e����R��e\��u�̒�^�]�,q�GF�!��i��	�S��P� �Ӌ�ռ/�l�2�Y�2���A\Ç�=,�3�X#��\�8(���@"%��F��{�,�U�2\�,�㕥������@��ܫ	E���AH)Faxj�MK���.�?Բ��!Kc��QR��ս�B75�U�|�%��(�PZx
�)��%*�Jb#���� �qO6W8lIY�/ȮU.����B��zc�J]B��(���F��)��ϧ�l�C�8q���*=4ںХ�b�Wj��r,���j���t���S��9>��m��\"̀�����%��u�C��֝���\�/lݱs�w�U����#�₲����F���پs�����NU�����a�+�f�]�u����]^��m�"��+�.Z��2��Fȃ��~RD�K*����c�AjSȊFWoX_5dk���(xF�=#?�Dd�.���"np�՚\c,"F.o����v���]�m��ι�\��f��/�27��a�X�F�j9�Q�>(|��8�ʳ�͖�����=�u� ߺ.���bR��ב#f`Ŋ�#�Gv0(�dU7?���
 �ˊ�o��c��;�&���o#oo#��>,�y)p^
6~)x�ġ{��`�^x��Д����D)L���hϷ�_ZxP:��mu�d�VGs��h~2hX��Ê=��}e�邃�#�p�g���1߬9����I�=`� Rb*������̮��i���c�P�B�Xy�H��c����,��� D~)��e��W)�E�ܦ�l�*�fy����R���LkM2&�	�����5���Ә͒֐=`f�C%��TC1=zT��O�����ivRc���k%zA�b�xpL(�jɠ6�w4\VI>��:�G��M#0.�v�Ñ1�{!q�R�#�{4��E�Z�["�>�W�y�E�q�a�ل�kn�8�p��?�s�%=�<�ʏ�9��Mh����L��l��	�Q(��\����v�C�w�ayO����o?=;Ʒ������xXN$�I�t��G�V%ZKc��i.�$���XR ��78r8X,��h-*7Il!�"��8kPd�*0	��7kβ���ab���`1��m-E�� )G�2
����C�;��E���3r1^�0��U�O����x}=RU���h4��l%�`LB��K�����p�`�a,�*���(���!�|�-v����+`qO���b����K;� C���Ƥ S��J�F�E5\��c4ϥ0f��Q"lmO-���qCN�)$Z� |��E�ڬb�^?Mz�
-�����c�q�3�Sy?�ň�FN���N�B�B_��6���Ya����!7:R����nO���[���s��ӈ&Y��a����}|^[�:؞J*�
oAn#�.���8��F���R�l|����{�̮�_��[{�=����y�k/��c�{��^��#�����VW��|7'-���Ϲ�����������-	�w\���O��Y��ꛗ��;�<p��������|�+���_�_D��_K��K� xh�N﷾mqE/wEc2��QCv��o&?{�'���?o�@��ܾߍ��[_���|��`��2��樝?r#o-R;_w���ӡv:4�&�P;�������N@�	H;�N���P;�������S�-o#��)H���@��*e���)�-�ë����@=�x�9Cg}�����?�#o�Q^A����9<�S��)��8���{�38G����Af���7�٬�93N�ՙ3�Lp�8sf�p��6̙9�|�3L��3sn�w���Mi��.y�ɜ��/�;h�1��$'9�INzߦ�~���  