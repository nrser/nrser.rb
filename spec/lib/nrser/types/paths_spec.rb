SPEC_FILE(
  spec_path: __FILE__,
  source_file: 'nrser/types/paths.rb',
  module: NRSER::Types,
) do

  METHOD :dir_path do
    include_examples 'make type',
      accepts: [
        '.',
        '/',
        Pathname.getwd,
      ],
      
      rejects: [
        'README.md',
      ],
      
      to_data: {
        Pathname.getwd => Pathname.getwd.to_s,
      }
      
  end # METHOD .dir_path
  
  
  METHOD :file_path do
    
    include_examples 'make type',
      accepts: [
        ( NRSER::ROOT / 'README.md' ),
      ],
      
      rejects: [
        '.',
        '/',
        Pathname.getwd,
      ],
      
      and_is_expected: {
        to: {
          have_attributes: {
            name: 'FilePath',
          }
        }
      }
    
    WHEN "custom name" do
      include_examples 'make type',
        args: [ name: 'CustomType' ],
        
        accepts: [
          ( NRSER::ROOT / 'README.md' ),
        ],
        
        rejects: [
          '.',
          '/',
          Pathname.getwd,
        ],
        
        and_is_expected: {
          to: {
            have_attributes: {
              name: 'CustomType',
            }
          }
        }
    end # WHEN custom name
      
  end # METHOD .dir_path
  
  
  METHOD :path_seg do
    include_examples 'make type',
      accepts: [
        'hey',
        'ho_let\'s goooo!'
      ],
      
      rejects: [
        'hey/ho',
      ],
      
      and_is_expected: {
        to: {
          have_attributes: {
            name: 'POSIXPathSegment',
          }
        }
      }
    
  end # METHOD .path_seg

  
  METHOD :tilde_path do
    
  end # METHOD .tilde_path Description

  
end # SPEC_FILE
